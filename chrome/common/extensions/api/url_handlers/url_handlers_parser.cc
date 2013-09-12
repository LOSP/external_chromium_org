// Copyright 2013 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "chrome/common/extensions/api/url_handlers/url_handlers_parser.h"

#include "base/command_line.h"
#include "base/memory/scoped_ptr.h"
#include "base/strings/string_number_conversions.h"
#include "base/strings/utf_string_conversions.h"
#include "base/values.h"
#include "chrome/common/extensions/extension_manifest_constants.h"
#include "chrome/common/extensions/manifest_handlers/offline_enabled_info.h"
#include "extensions/common/error_utils.h"
#include "extensions/common/switches.h"
#include "net/base/network_change_notifier.h"
#include "url/gurl.h"

using base::ASCIIToUTF16;
using net::NetworkChangeNotifier;

namespace mkeys = extensions::manifest_keys;
namespace merrors = extension_manifest_errors;

// TODO(sergeygs): Use the same strategy that externally_connectable does for
// parsing the manifest: declare a schema for the manifest entry in
// manifest_types.json, then use it here.
//
// See:
// chrome/common/extensions/api/manifest_types.json
// chrome/common/extensions/manifest_handlers/externally_connectable.*
//
// Do the same in (at least) file_handlers_parser.cc as well.

namespace extensions {

UrlHandlerInfo::UrlHandlerInfo() {
}

UrlHandlerInfo::~UrlHandlerInfo() {
}

UrlHandlers::UrlHandlers() {
}

UrlHandlers::~UrlHandlers() {
}

// static
const std::vector<UrlHandlerInfo>* UrlHandlers::GetUrlHandlers(
    const Extension* extension) {
  UrlHandlers* info = static_cast<UrlHandlers*>(
      extension->GetManifestData(mkeys::kUrlHandlers));
  return info ? &info->handlers : NULL;
}

// static
bool UrlHandlers::CanExtensionHandleUrl(
    const Extension* extension,
    const GURL& url) {
  return FindMatchingUrlHandler(extension, url) != NULL;
}

// static
const UrlHandlerInfo* UrlHandlers::FindMatchingUrlHandler(
    const Extension* extension,
    const GURL& url) {
  const std::vector<UrlHandlerInfo>* handlers = GetUrlHandlers(extension);
  if (!handlers)
    return NULL;

  if (NetworkChangeNotifier::IsOffline() &&
      !OfflineEnabledInfo::IsOfflineEnabled(extension))
    return NULL;

  for (std::vector<extensions::UrlHandlerInfo>::const_iterator it =
       handlers->begin(); it != handlers->end(); it++) {
    if (it->patterns.MatchesURL(url))
      return &(*it);
  }

  return NULL;
}

UrlHandlersParser::UrlHandlersParser() {
}

UrlHandlersParser::~UrlHandlersParser() {
}

bool ParseUrlHandler(const std::string& handler_id,
                     const DictionaryValue& handler_info,
                     std::vector<UrlHandlerInfo>* url_handlers,
                     string16* error) {
  DCHECK(error);

  UrlHandlerInfo handler;
  handler.id = handler_id;

  if (!handler_info.GetString(mkeys::kUrlHandlerTitle, &handler.title)) {
    *error = ASCIIToUTF16(merrors::kInvalidURLHandlerTitle);
    return false;
  }

  const ListValue* manif_patterns = NULL;
  if (!handler_info.GetList(mkeys::kMatches, &manif_patterns) ||
      manif_patterns->GetSize() == 0) {
    *error = ErrorUtils::FormatErrorMessageUTF16(
        merrors::kInvalidURLHandlerPattern, handler_id);
    return false;
  }

  for (ListValue::const_iterator it = manif_patterns->begin();
       it != manif_patterns->end(); ++it) {
    std::string str_pattern;
    (*it)->GetAsString(&str_pattern);
    // TODO(sergeygs): Limit this to non-top-level domains.
    // TODO(sergeygs): Also add a verification to the CWS installer that the
    // URL patterns claimed here belong to the app's author verified sites.
    URLPattern pattern(URLPattern::SCHEME_HTTP |
                       URLPattern::SCHEME_HTTPS);
    if (pattern.Parse(str_pattern) != URLPattern::PARSE_SUCCESS) {
      *error = ErrorUtils::FormatErrorMessageUTF16(
          merrors::kInvalidURLHandlerPatternElement, handler_id);
      return false;
    }
    handler.patterns.AddPattern(pattern);
  }

  url_handlers->push_back(handler);

  return true;
}

bool UrlHandlersParser::Parse(Extension* extension, string16* error) {
  scoped_ptr<UrlHandlers> info(new UrlHandlers);
  const DictionaryValue* all_handlers = NULL;
  if (!extension->manifest()->GetDictionary(
        mkeys::kUrlHandlers, &all_handlers)) {
    *error = ASCIIToUTF16(merrors::kInvalidURLHandlers);
    return false;
  }

  DCHECK(extension->is_platform_app());

  for (DictionaryValue::Iterator iter(*all_handlers); !iter.IsAtEnd();
       iter.Advance()) {
    // A URL handler entry is a title and a list of URL patterns to handle.
    const DictionaryValue* handler = NULL;
    if (!iter.value().GetAsDictionary(&handler)) {
      *error = ASCIIToUTF16(merrors::kInvalidURLHandlerPatternElement);
      return false;
    }

    if (!ParseUrlHandler(iter.key(), *handler, &info->handlers, error)) {
      // Text in |error| is set by ParseUrlHandler.
      return false;
    }
  }

  extension->SetManifestData(mkeys::kUrlHandlers, info.release());

  return true;
}

const std::vector<std::string> UrlHandlersParser::Keys() const {
  return SingleKey(mkeys::kUrlHandlers);
}

}  // namespace extensions
