// Copyright 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef UI_GFX_TEXT_UTILS_H_
#define UI_GFX_TEXT_UTILS_H_

#include "base/strings/string16.h"
#include "ui/gfx/gfx_export.h"

namespace gfx {

class FontList;

// Strip the accelerator char (typically '&') from a menu string.  A double
// accelerator char ('&&') will be converted to a single char.  The out params
// |accelerated_char_pos| and |accelerated_char_span| will be set to the index
// and span of the last accelerated character, respectively, or -1 and 0 if
// there was none.
UI_EXPORT base::string16 RemoveAcceleratorChar(const base::string16& s,
                                               base::char16 accelerator_char,
                                               int* accelerated_char_pos,
                                               int* accelerated_char_span);

// Returns the number of horizontal pixels needed to display the specified
// |text| with |font_list|.
UI_EXPORT int GetStringWidth(const base::string16& text,
                             const FontList& font_list);

}  // namespace gfx

#endif  // UI_GFX_TEXT_UTILS_H_
