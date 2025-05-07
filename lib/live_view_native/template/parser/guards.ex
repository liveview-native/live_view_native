defmodule LiveViewNative.Template.Parser.Guards do
  @moduledoc """
  Provides defguards for validating Unicode code points according to VML rules
  for different parts of a VML document.
  """

  #--------------------------------------------------------------------------------
  # Region: Module Attributes (Ranges and Forbidden Codepoints for Guards)
  #--------------------------------------------------------------------------------

  # The @valid_text_attribute_ranges attribute below was the source for the hardcoded ranges
  # in the `is_valid_attribute_value_char` guard. It's commented out to prevent Elixir
  # warnings about an unused module attribute, as the guard itself contains the expanded logic
  # due to guard limitations (guards cannot directly iterate over such lists using Enum.any?/2).
  # If these ranges need to be updated, uncomment this list, make changes, and then
  # manually update the corresponding conditions in the `is_valid_attribute_value_char` guard.
  # @valid_text_attribute_ranges [
  #   # Control characters allowed as "space characters"
  #   9..9,          # U+0009 (Tab)
  #   10..10,        # U+000A (Line Feed)
  #   12..12,        # U+000C (Form Feed)
  #   13..13,        # U+000D (Carriage Return)
  #   # Space and printable ASCII (excluding U+007F DEL and other C0 controls)
  #   32..126,       # U+0020 to U+007E
  #   # Most of Basic Multilingual Plane (BMP)
  #   160..55295,    # U+00A0 to U+D7FF (before surrogates)
  #   # BMP Private Use Area and other characters
  #   57344..64975,  # U+E000 to U+FDCF (before noncharacter block U+FDD0-U+FDEF)
  #   65008..65533,  # U+FDF0 to U+FFFD (after noncharacter block, before U+FFFE, U+FFFF)
  #   # Supplementary Planes (U+10000 to U+10FFFF)
  #   65536..131069,    # Plane 1:  U+10000 to U+1FFFD
  #   131072..196605,   # Plane 2:  U+20000 to U+2FFFD
  #   196608..262141,   # Plane 3:  U+30000 to U+3FFFD
  #   262144..327677,   # Plane 4:  U+40000 to U+4FFFD
  #   327680..393213,   # Plane 5:  U+50000 to U+5FFFD
  #   393216..458749,   # Plane 6:  U+60000 to U+6FFFD
  #   458752..524285,   # Plane 7:  U+70000 to U+7FFFD
  #   524288..589821,   # Plane 8:  U+80000 to U+8FFFD
  #   589824..655357,   # Plane 9:  U+90000 to U+9FFFD
  #   655360..720893,   # Plane 10: U+A0000 to U+AFFFD
  #   720896..786429,   # Plane 11: U+B0000 to U+BFFFD
  #   786432..851965,   # Plane 12: U+C0000 to U+CFFFD
  #   851968..917501,   # Plane 13: U+D0000 to U+DFFFD
  #   917504..983037,   # Plane 14: U+E0000 to U+EFFFD
  #   983040..1048573,  # Plane 15: U+F0000 to U+FFFFD
  #   1048576..1114109  # Plane 16: U+100000 to U+10FFFD
  # ]

  base_nonchars = Enum.to_list(0xFDD0..0xFDEF)
  plane_end_nonchars =
    for plane_idx <- 0..16, suffix <- [0xFFFE, 0xFFFF], do: plane_idx * 0x10000 + suffix
    
  @noncharacter_codepoints (base_nonchars ++ plane_end_nonchars)
    |> Enum.uniq()
    |> Enum.filter(&(&1 <= 0x10FFFF))

  @forbidden_attr_name_specific_codepoints [
    0x0020, # SPACE
    0x0022, # " (Quotation Mark)
    0x0027, # ' (Apostrophe)
    0x003C, # < (Less-than Sign)
    0x003E, # > (Greater-than Sign)
    0x002F, # / (Solidus / Slash)
    0x003D  # = (Equals Sign)
  ]

  #--------------------------------------------------------------------------------
  # Region: Private Helper Guards
  #--------------------------------------------------------------------------------

  defguardp is_control_character_guard(codepoint) when
    is_integer(codepoint) and
    (
      (codepoint >= 0x0000 and codepoint <= 0x001F) or # C0 controls (includes NUL)
      (codepoint >= 0x007F and codepoint <= 0x009F)    # DEL and C1 controls
    )

  defguardp is_noncharacter_guard(codepoint) when
    is_integer(codepoint) and codepoint in @noncharacter_codepoints

  defguardp is_forbidden_attr_name_specific_char_guard(codepoint) when
    is_integer(codepoint) and codepoint in @forbidden_attr_name_specific_codepoints

  defguardp is_ascii_letter_guard(codepoint) when
    is_integer(codepoint) and
    (
      (codepoint >= ?a and codepoint <= ?z) or
      (codepoint >= ?A and codepoint <= ?Z)
    )

  defguardp is_ascii_digit_guard(codepoint) when
    is_integer(codepoint) and
    (codepoint >= ?0 and codepoint <= ?9)

  #--------------------------------------------------------------------------------
  # Region: Public Guards for Single Codepoint Validation
  #--------------------------------------------------------------------------------

  @doc """
  Guard: Checks if a given Unicode code point is valid for VML text content or attribute values.
  The conditions below are an expansion of the (now commented out) @valid_text_attribute_ranges.
  """
  defguard is_valid_attribute_value_char(codepoint) when
    is_integer(codepoint) and
    (
      (codepoint >= 9 and codepoint <= 9) or # Tab
      (codepoint >= 10 and codepoint <= 10) or # LF
      (codepoint >= 12 and codepoint <= 12) or # FF
      (codepoint >= 13 and codepoint <= 13) or # CR
      (codepoint >= 32 and codepoint <= 126) or
      (codepoint >= 160 and codepoint <= 55295) or
      (codepoint >= 57344 and codepoint <= 64975) or
      (codepoint >= 65008 and codepoint <= 65533) or
      (codepoint >= 65536 and codepoint <= 131069) or
      (codepoint >= 131072 and codepoint <= 196605) or
      (codepoint >= 196608 and codepoint <= 262141) or
      (codepoint >= 262144 and codepoint <= 327677) or
      (codepoint >= 327680 and codepoint <= 393213) or
      (codepoint >= 393216 and codepoint <= 458749) or
      (codepoint >= 458752 and codepoint <= 524285) or
      (codepoint >= 524288 and codepoint <= 589821) or
      (codepoint >= 589824 and codepoint <= 655357) or
      (codepoint >= 655360 and codepoint <= 720893) or
      (codepoint >= 720896 and codepoint <= 786429) or
      (codepoint >= 786432 and codepoint <= 851965) or
      (codepoint >= 851968 and codepoint <= 917501) or
      (codepoint >= 917504 and codepoint <= 983037) or
      (codepoint >= 983040 and codepoint <= 1048573) or
      (codepoint >= 1048576 and codepoint <= 1114109)
    )

  @doc """
  Guard: Checks if a given Unicode code point is valid for a VML attribute name.
  """
  defguard is_valid_attribute_name_char(codepoint) when
    is_integer(codepoint) and
    not (
      is_control_character_guard(codepoint) or
      is_noncharacter_guard(codepoint) or
      is_forbidden_attr_name_specific_char_guard(codepoint)
    )

  @doc """
  Guard: Checks if a codepoint is valid as the first character of a VML tag name.
  """
  defguard is_valid_tag_name_first_char(codepoint) when
    is_ascii_letter_guard(codepoint)

  @doc """
  Guard: Checks if a codepoint is valid as a subsequent character in a VML tag name.
  """
  defguard is_valid_tag_name_subsequent_char(codepoint) when
    is_integer(codepoint) and
    (
      is_ascii_letter_guard(codepoint) or
      is_ascii_digit_guard(codepoint) or
      codepoint == ?- or # hyphen
      codepoint == ?.    # period
    )

end
