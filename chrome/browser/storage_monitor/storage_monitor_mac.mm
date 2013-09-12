// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "chrome/browser/storage_monitor/storage_monitor_mac.h"

#include "base/mac/foundation_util.h"
#include "base/mac/mac_util.h"
#include "base/strings/sys_string_conversions.h"
#include "base/strings/utf_string_conversions.h"
#include "chrome/browser/storage_monitor/image_capture_device_manager.h"
#include "chrome/browser/storage_monitor/media_storage_util.h"
#include "chrome/browser/storage_monitor/storage_info.h"
#include "content/public/browser/browser_thread.h"

namespace chrome {

namespace {

const char kDiskImageModelName[] = "Disk Image";

string16 GetUTF16FromDictionary(CFDictionaryRef dictionary, CFStringRef key) {
  CFStringRef value =
      base::mac::GetValueFromDictionary<CFStringRef>(dictionary, key);
  if (!value)
    return string16();
  return base::SysCFStringRefToUTF16(value);
}

string16 JoinName(const string16& name, const string16& addition) {
  if (addition.empty())
    return name;
  if (name.empty())
    return addition;
  return name + static_cast<char16>(' ') + addition;
}

StorageInfo::Type GetDeviceType(bool is_removable, bool has_dcim) {
  if (!is_removable)
    return StorageInfo::FIXED_MASS_STORAGE;
  if (has_dcim)
    return StorageInfo::REMOVABLE_MASS_STORAGE_WITH_DCIM;
  return StorageInfo::REMOVABLE_MASS_STORAGE_NO_DCIM;
}

StorageInfo BuildStorageInfo(
    CFDictionaryRef dict, std::string* bsd_name) {
  DCHECK(content::BrowserThread::CurrentlyOn(content::BrowserThread::FILE));

  CFStringRef device_bsd_name = base::mac::GetValueFromDictionary<CFStringRef>(
      dict, kDADiskDescriptionMediaBSDNameKey);
  if (device_bsd_name && bsd_name)
    *bsd_name = base::SysCFStringRefToUTF8(device_bsd_name);

  CFURLRef url = base::mac::GetValueFromDictionary<CFURLRef>(
      dict, kDADiskDescriptionVolumePathKey);
  NSURL* nsurl = base::mac::CFToNSCast(url);
  base::FilePath location = base::mac::NSStringToFilePath([nsurl path]);
  CFNumberRef size_number =
      base::mac::GetValueFromDictionary<CFNumberRef>(
          dict, kDADiskDescriptionMediaSizeKey);
  uint64 size_in_bytes = 0;
  if (size_number)
    CFNumberGetValue(size_number, kCFNumberLongLongType, &size_in_bytes);

  string16 vendor = GetUTF16FromDictionary(
      dict, kDADiskDescriptionDeviceVendorKey);
  string16 model = GetUTF16FromDictionary(
      dict, kDADiskDescriptionDeviceModelKey);
  string16 label = GetUTF16FromDictionary(
      dict, kDADiskDescriptionVolumeNameKey);

  CFUUIDRef uuid = base::mac::GetValueFromDictionary<CFUUIDRef>(
      dict, kDADiskDescriptionVolumeUUIDKey);
  std::string unique_id;
  if (uuid) {
    base::ScopedCFTypeRef<CFStringRef> uuid_string(
        CFUUIDCreateString(NULL, uuid));
    if (uuid_string.get())
      unique_id = base::SysCFStringRefToUTF8(uuid_string);
  }
  if (unique_id.empty()) {
    string16 revision = GetUTF16FromDictionary(
        dict, kDADiskDescriptionDeviceRevisionKey);
    string16 unique_id2 = vendor;
    unique_id2 = JoinName(unique_id2, model);
    unique_id2 = JoinName(unique_id2, revision);
    unique_id = UTF16ToUTF8(unique_id2);
  }

  CFBooleanRef is_removable_ref =
      base::mac::GetValueFromDictionary<CFBooleanRef>(
          dict, kDADiskDescriptionMediaRemovableKey);
  bool is_removable = is_removable_ref && CFBooleanGetValue(is_removable_ref);
  // Checking for DCIM only matters on removable devices.
  bool has_dcim = is_removable && MediaStorageUtil::HasDcim(location);
  StorageInfo::Type device_type = GetDeviceType(is_removable, has_dcim);
  std::string device_id;
  if (!unique_id.empty())
    device_id = StorageInfo::MakeDeviceId(device_type, unique_id);

  return StorageInfo(device_id, string16(), location.value(), label, vendor,
                     model, size_in_bytes);
}

void GetDiskInfoAndUpdateOnFileThread(
    const base::WeakPtr<StorageMonitorMac>& monitor,
    base::ScopedCFTypeRef<CFDictionaryRef> dict,
    StorageMonitorMac::UpdateType update_type) {
  DCHECK(content::BrowserThread::CurrentlyOn(content::BrowserThread::FILE));

  std::string bsd_name;
  StorageInfo info = BuildStorageInfo(dict, &bsd_name);

  content::BrowserThread::PostTask(
      content::BrowserThread::UI,
      FROM_HERE,
      base::Bind(&StorageMonitorMac::UpdateDisk,
                 monitor,
                 bsd_name,
                 info,
                 update_type));
}

struct EjectDiskOptions {
  std::string bsd_name;
  base::Callback<void(StorageMonitor::EjectStatus)> callback;
  base::ScopedCFTypeRef<DADiskRef> disk;
};

void PostEjectCallback(DADiskRef disk,
                       DADissenterRef dissenter,
                       void* context) {
  scoped_ptr<EjectDiskOptions> options_deleter(
      static_cast<EjectDiskOptions*>(context));
  if (dissenter) {
    options_deleter->callback.Run(StorageMonitor::EJECT_IN_USE);
    return;
  }

  options_deleter->callback.Run(StorageMonitor::EJECT_OK);
}

void PostUnmountCallback(DADiskRef disk,
                         DADissenterRef dissenter,
                         void* context) {
  scoped_ptr<EjectDiskOptions> options_deleter(
      static_cast<EjectDiskOptions*>(context));
  if (dissenter) {
    options_deleter->callback.Run(StorageMonitor::EJECT_IN_USE);
    return;
  }

  DADiskEject(options_deleter->disk.get(), kDADiskEjectOptionDefault,
              PostEjectCallback, options_deleter.release());
}

void EjectDisk(EjectDiskOptions* options) {
  DADiskUnmount(options->disk.get(), kDADiskUnmountOptionWhole,
                PostUnmountCallback, options);
}

}  // namespace

StorageMonitorMac::StorageMonitorMac() : pending_disk_updates_(0) {
}

StorageMonitorMac::~StorageMonitorMac() {
  if (session_.get()) {
    DASessionUnscheduleFromRunLoop(
        session_, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
  }
}

void StorageMonitorMac::Init() {
  session_.reset(DASessionCreate(NULL));

  // Register for callbacks for attached, changed, and removed devices.
  // This will send notifications for existing devices too.
  DARegisterDiskAppearedCallback(
      session_,
      kDADiskDescriptionMatchVolumeMountable,
      DiskAppearedCallback,
      this);
  DARegisterDiskDisappearedCallback(
      session_,
      kDADiskDescriptionMatchVolumeMountable,
      DiskDisappearedCallback,
      this);
  DARegisterDiskDescriptionChangedCallback(
      session_,
      kDADiskDescriptionMatchVolumeMountable,
      kDADiskDescriptionWatchVolumePath,
      DiskDescriptionChangedCallback,
      this);

  DASessionScheduleWithRunLoop(
      session_, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);

  if (base::mac::IsOSLionOrLater()) {
    image_capture_device_manager_.reset(new chrome::ImageCaptureDeviceManager);
    image_capture_device_manager_->SetNotifications(receiver());
  }
}

void StorageMonitorMac::UpdateDisk(
    const std::string& bsd_name,
    const StorageInfo& info,
    UpdateType update_type) {
  DCHECK(content::BrowserThread::CurrentlyOn(content::BrowserThread::UI));

  pending_disk_updates_--;
  bool initialization_complete = false;
  if (!IsInitialized() && pending_disk_updates_ == 0)
    initialization_complete = true;

  if (info.device_id().empty() || bsd_name.empty()) {
    if (initialization_complete)
      MarkInitialized();
    return;
  }

  std::map<std::string, StorageInfo>::iterator it =
      disk_info_map_.find(bsd_name);
  if (it != disk_info_map_.end()) {
    // If an attached notification was previously posted then post a detached
    // notification now. This is used for devices that are being removed or
    // devices that have changed.
    if (ShouldPostNotificationForDisk(it->second)) {
      receiver()->ProcessDetach(it->second.device_id());
    }
  }

  if (update_type == UPDATE_DEVICE_REMOVED) {
    if (it != disk_info_map_.end())
      disk_info_map_.erase(it);
  } else {
    disk_info_map_[bsd_name] = info;
    MediaStorageUtil::RecordDeviceInfoHistogram(true, info.device_id(),
                                                info.storage_label());
    if (ShouldPostNotificationForDisk(info))
      receiver()->ProcessAttach(info);
  }

  // We're not really honestly sure we're done, but this looks the best we
  // can do. Any misses should go out through notifications.
  if (initialization_complete)
    MarkInitialized();
}

bool StorageMonitorMac::GetStorageInfoForPath(const base::FilePath& path,
                                              StorageInfo* device_info) const {
  DCHECK(device_info);

  if (!path.IsAbsolute())
    return false;

  base::FilePath current = path;
  const base::FilePath root(base::FilePath::kSeparators);
  while (current != root) {
    StorageInfo info;
    if (FindDiskWithMountPoint(current, &info)) {
      *device_info = info;
      return true;
    }
    current = current.DirName();
  }

  return false;
}

void StorageMonitorMac::EjectDevice(
      const std::string& device_id,
      base::Callback<void(EjectStatus)> callback) {
  StorageInfo::Type type;
  std::string uuid;
  if (!StorageInfo::CrackDeviceId(device_id, &type, &uuid)) {
    callback.Run(EJECT_FAILURE);
    return;
  }

  if (type == StorageInfo::MAC_IMAGE_CAPTURE &&
      image_capture_device_manager_.get()) {
    image_capture_device_manager_->EjectDevice(uuid, callback);
    return;
  }

  std::string bsd_name;
  for (std::map<std::string, StorageInfo>::iterator
      it = disk_info_map_.begin(); it != disk_info_map_.end(); ++it) {
    if (it->second.device_id() == device_id) {
      bsd_name = it->first;
      disk_info_map_.erase(it);
      break;
    }
  }

  if (bsd_name.empty()) {
    callback.Run(EJECT_NO_SUCH_DEVICE);
    return;
  }

  receiver()->ProcessDetach(device_id);

  base::ScopedCFTypeRef<DADiskRef> disk(
      DADiskCreateFromBSDName(NULL, session_, bsd_name.c_str()));
  if (!disk.get()) {
    callback.Run(StorageMonitor::EJECT_FAILURE);
    return;
  }
  // Get the reference to the full disk for ejecting.
  disk.reset(DADiskCopyWholeDisk(disk));
  if (!disk.get()) {
    callback.Run(StorageMonitor::EJECT_FAILURE);
    return;
  }

  EjectDiskOptions* options = new EjectDiskOptions;
  options->bsd_name = bsd_name;
  options->callback = callback;
  options->disk.reset(disk.release());
  content::BrowserThread::PostTask(content::BrowserThread::UI, FROM_HERE,
                                   base::Bind(EjectDisk, options));
}

// static
void StorageMonitorMac::DiskAppearedCallback(DADiskRef disk, void* context) {
  StorageMonitorMac* monitor = static_cast<StorageMonitorMac*>(context);
  monitor->GetDiskInfoAndUpdate(disk, UPDATE_DEVICE_ADDED);
}

// static
void StorageMonitorMac::DiskDisappearedCallback(DADiskRef disk, void* context) {
  StorageMonitorMac* monitor = static_cast<StorageMonitorMac*>(context);
  monitor->GetDiskInfoAndUpdate(disk, UPDATE_DEVICE_REMOVED);
}

// static
void StorageMonitorMac::DiskDescriptionChangedCallback(DADiskRef disk,
                                                       CFArrayRef keys,
                                                       void *context) {
  StorageMonitorMac* monitor = static_cast<StorageMonitorMac*>(context);
  monitor->GetDiskInfoAndUpdate(disk, UPDATE_DEVICE_CHANGED);
}

void StorageMonitorMac::GetDiskInfoAndUpdate(
    DADiskRef disk,
    StorageMonitorMac::UpdateType update_type) {
  DCHECK(content::BrowserThread::CurrentlyOn(content::BrowserThread::UI));

  pending_disk_updates_++;

  base::ScopedCFTypeRef<CFDictionaryRef> dict(DADiskCopyDescription(disk));
  content::BrowserThread::PostTask(
      content::BrowserThread::FILE,
      FROM_HERE,
      base::Bind(GetDiskInfoAndUpdateOnFileThread,
                 AsWeakPtr(), dict, update_type));
}


bool StorageMonitorMac::ShouldPostNotificationForDisk(
    const StorageInfo& info) const {
  // Only post notifications about disks that have no empty fields and
  // are removable. Also exclude disk images (DMGs).
  return !info.device_id().empty() &&
         !info.location().empty() &&
         info.model_name() != ASCIIToUTF16(kDiskImageModelName) &&
         StorageInfo::IsMassStorageDevice(info.device_id());
}

bool StorageMonitorMac::FindDiskWithMountPoint(
    const base::FilePath& mount_point,
    StorageInfo* info) const {
  for (std::map<std::string, StorageInfo>::const_iterator
      it = disk_info_map_.begin(); it != disk_info_map_.end(); ++it) {
    if (it->second.location() == mount_point.value()) {
      *info = it->second;
      return true;
    }
  }
  return false;
}

StorageMonitor* StorageMonitor::Create() {
  return new StorageMonitorMac();
}

}  // namespace chrome
