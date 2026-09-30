#include "tree_sitter/parser.h"

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 14
#define STATE_COUNT 19
#define LARGE_STATE_COUNT 8
#define SYMBOL_COUNT 22
#define ALIAS_COUNT 0
#define TOKEN_COUNT 13
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 0
#define MAX_ALIAS_SEQUENCE_LENGTH 3
#define PRODUCTION_ID_COUNT 1

enum ts_symbol_identifiers {
  anon_sym_LBRACE = 1,
  anon_sym_RBRACE = 2,
  anon_sym_LBRACK = 3,
  anon_sym_RBRACK = 4,
  anon_sym_COLON = 5,
  sym_identifier = 6,
  sym_id_reference = 7,
  sym_plain_scalar = 8,
  sym_string = 9,
  sym_multiline = 10,
  sym_paren = 11,
  sym_comment = 12,
  sym_document = 13,
  sym_map = 14,
  sym_vector = 15,
  sym_pair = 16,
  sym_field = 17,
  sym__value = 18,
  sym_reserved = 19,
  aux_sym_map_repeat1 = 20,
  aux_sym_vector_repeat1 = 21,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [anon_sym_LBRACE] = "{",
  [anon_sym_RBRACE] = "}",
  [anon_sym_LBRACK] = "[",
  [anon_sym_RBRACK] = "]",
  [anon_sym_COLON] = ":",
  [sym_identifier] = "identifier",
  [sym_id_reference] = "id_reference",
  [sym_plain_scalar] = "plain_scalar",
  [sym_string] = "string",
  [sym_multiline] = "multiline",
  [sym_paren] = "paren",
  [sym_comment] = "comment",
  [sym_document] = "document",
  [sym_map] = "map",
  [sym_vector] = "vector",
  [sym_pair] = "pair",
  [sym_field] = "field",
  [sym__value] = "_value",
  [sym_reserved] = "reserved",
  [aux_sym_map_repeat1] = "map_repeat1",
  [aux_sym_vector_repeat1] = "vector_repeat1",
};

static const TSSymbol ts_symbol_map[] = {
  [ts_builtin_sym_end] = ts_builtin_sym_end,
  [anon_sym_LBRACE] = anon_sym_LBRACE,
  [anon_sym_RBRACE] = anon_sym_RBRACE,
  [anon_sym_LBRACK] = anon_sym_LBRACK,
  [anon_sym_RBRACK] = anon_sym_RBRACK,
  [anon_sym_COLON] = anon_sym_COLON,
  [sym_identifier] = sym_identifier,
  [sym_id_reference] = sym_id_reference,
  [sym_plain_scalar] = sym_plain_scalar,
  [sym_string] = sym_string,
  [sym_multiline] = sym_multiline,
  [sym_paren] = sym_paren,
  [sym_comment] = sym_comment,
  [sym_document] = sym_document,
  [sym_map] = sym_map,
  [sym_vector] = sym_vector,
  [sym_pair] = sym_pair,
  [sym_field] = sym_field,
  [sym__value] = sym__value,
  [sym_reserved] = sym_reserved,
  [aux_sym_map_repeat1] = aux_sym_map_repeat1,
  [aux_sym_vector_repeat1] = aux_sym_vector_repeat1,
};

static const TSSymbolMetadata ts_symbol_metadata[] = {
  [ts_builtin_sym_end] = {
    .visible = false,
    .named = true,
  },
  [anon_sym_LBRACE] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_RBRACE] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_LBRACK] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_RBRACK] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_COLON] = {
    .visible = true,
    .named = false,
  },
  [sym_identifier] = {
    .visible = true,
    .named = true,
  },
  [sym_id_reference] = {
    .visible = true,
    .named = true,
  },
  [sym_plain_scalar] = {
    .visible = true,
    .named = true,
  },
  [sym_string] = {
    .visible = true,
    .named = true,
  },
  [sym_multiline] = {
    .visible = true,
    .named = true,
  },
  [sym_paren] = {
    .visible = true,
    .named = true,
  },
  [sym_comment] = {
    .visible = true,
    .named = true,
  },
  [sym_document] = {
    .visible = true,
    .named = true,
  },
  [sym_map] = {
    .visible = true,
    .named = true,
  },
  [sym_vector] = {
    .visible = true,
    .named = true,
  },
  [sym_pair] = {
    .visible = true,
    .named = true,
  },
  [sym_field] = {
    .visible = true,
    .named = true,
  },
  [sym__value] = {
    .visible = false,
    .named = true,
  },
  [sym_reserved] = {
    .visible = true,
    .named = true,
  },
  [aux_sym_map_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_vector_repeat1] = {
    .visible = false,
    .named = false,
  },
};

static const TSSymbol ts_alias_sequences[PRODUCTION_ID_COUNT][MAX_ALIAS_SEQUENCE_LENGTH] = {
  [0] = {0},
};

static const uint16_t ts_non_terminal_alias_map[] = {
  0,
};

static const TSStateId ts_primary_state_ids[STATE_COUNT] = {
  [0] = 0,
  [1] = 1,
  [2] = 2,
  [3] = 3,
  [4] = 4,
  [5] = 5,
  [6] = 6,
  [7] = 7,
  [8] = 8,
  [9] = 9,
  [10] = 10,
  [11] = 11,
  [12] = 12,
  [13] = 13,
  [14] = 14,
  [15] = 15,
  [16] = 16,
  [17] = 17,
  [18] = 18,
};

static TSCharacterRange sym_id_reference_character_set_1[] = {
  {0, 0x08}, {0x0e, 0x1f}, {'!', '!'}, {'#', '\''}, {'*', '+'}, {'-', '9'}, {'<', '?'}, {'A', 'Z'},
  {'^', '_'}, {'a', 'z'}, {'|', '|'}, {'~', 0x10ffff},
};

static TSCharacterRange sym_id_reference_character_set_2[] = {
  {0, 0x08}, {0x0e, 0x1f}, {'!', '!'}, {'#', '\''}, {'+', '+'}, {'-', '.'}, {'0', '9'}, {'<', '?'},
  {'A', 'Z'}, {'^', '_'}, {'a', 'z'}, {'|', '|'}, {'~', 0x10ffff},
};

static TSCharacterRange sym_plain_scalar_character_set_1[] = {
  {0, 0x08}, {0x0e, 0x1f}, {'!', '!'}, {'$', '&'}, {'*', '+'}, {'-', '9'}, {'<', '?'}, {'A', 'Z'},
  {'_', '_'}, {'a', 'z'}, {'|', '|'}, {0x7f, 0x10ffff},
};

static TSCharacterRange sym_plain_scalar_character_set_2[] = {
  {0, 0x08}, {0x0e, 0x1f}, {'!', '!'}, {'$', '&'}, {'+', '+'}, {'-', '.'}, {'0', '9'}, {'<', '?'},
  {'A', 'Z'}, {'_', '_'}, {'a', 'z'}, {'|', '|'}, {0x7f, 0x10ffff},
};

static bool ts_lex(TSLexer *lexer, TSStateId state) {
  START_LEXER();
  eof = lexer->eof(lexer);
  switch (state) {
    case 0:
      if (eof) ADVANCE(9);
      if (lookahead == '"') ADVANCE(1);
      if (lookahead == '(') ADVANCE(2);
      if (lookahead == ',') SKIP(0);
      if (lookahead == '/') ADVANCE(3);
      if (lookahead == ':') ADVANCE(14);
      if (lookahead == '@') ADVANCE(16);
      if (lookahead == '[') ADVANCE(12);
      if (lookahead == ']') ADVANCE(13);
      if (lookahead == '`') ADVANCE(4);
      if (lookahead == '{') ADVANCE(10);
      if (lookahead == '}') ADVANCE(11);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(0);
      if (('a' <= lookahead && lookahead <= 'z')) ADVANCE(15);
      END_STATE();
    case 1:
      if (lookahead == '"') ADVANCE(21);
      if (lookahead == '\\') ADVANCE(6);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '\r') ADVANCE(1);
      END_STATE();
    case 2:
      if (lookahead == ')') ADVANCE(23);
      if (lookahead != 0 &&
          lookahead != '(' &&
          lookahead != ')') ADVANCE(2);
      END_STATE();
    case 3:
      if (lookahead == '/') ADVANCE(24);
      END_STATE();
    case 4:
      if (lookahead == '\\') ADVANCE(7);
      if (lookahead == '`') ADVANCE(22);
      if (lookahead != 0) ADVANCE(4);
      END_STATE();
    case 5:
      if (('0' <= lookahead && lookahead <= '9') ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(15);
      END_STATE();
    case 6:
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(1);
      END_STATE();
    case 7:
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(4);
      END_STATE();
    case 8:
      if (eof) ADVANCE(9);
      if (lookahead == '"') ADVANCE(1);
      if (lookahead == '(') ADVANCE(2);
      if (lookahead == ',') SKIP(8);
      if (lookahead == '/') ADVANCE(18);
      if (lookahead == ':') ADVANCE(14);
      if (lookahead == '@') ADVANCE(16);
      if (lookahead == '[') ADVANCE(12);
      if (lookahead == ']') ADVANCE(13);
      if (lookahead == '`') ADVANCE(4);
      if (lookahead == '{') ADVANCE(10);
      if (lookahead == '}') ADVANCE(11);
      if (lookahead == '\t' ||
          lookahead == '\n' ||
          lookahead == '\r' ||
          lookahead == ' ') SKIP(8);
      if (lookahead != 0 &&
          (lookahead < '\t' || '\r' < lookahead) &&
          lookahead != '"' &&
          lookahead != '#' &&
          (lookahead < '\'' || ')' < lookahead) &&
          lookahead != ':' &&
          lookahead != ';' &&
          (lookahead < '[' || '^' < lookahead) &&
          lookahead != '}' &&
          lookahead != '~') ADVANCE(19);
      END_STATE();
    case 9:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 10:
      ACCEPT_TOKEN(anon_sym_LBRACE);
      END_STATE();
    case 11:
      ACCEPT_TOKEN(anon_sym_RBRACE);
      END_STATE();
    case 12:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 13:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 14:
      ACCEPT_TOKEN(anon_sym_COLON);
      END_STATE();
    case 15:
      ACCEPT_TOKEN(sym_identifier);
      if (lookahead == '-') ADVANCE(5);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(15);
      END_STATE();
    case 16:
      ACCEPT_TOKEN(sym_id_reference);
      if (lookahead == '/') ADVANCE(17);
      if ((!eof && set_contains(sym_id_reference_character_set_1, 12, lookahead))) ADVANCE(16);
      END_STATE();
    case 17:
      ACCEPT_TOKEN(sym_id_reference);
      if ((!eof && set_contains(sym_id_reference_character_set_2, 13, lookahead))) ADVANCE(16);
      END_STATE();
    case 18:
      ACCEPT_TOKEN(sym_plain_scalar);
      if (lookahead == '/') ADVANCE(24);
      if ((!eof && set_contains(sym_plain_scalar_character_set_2, 13, lookahead))) ADVANCE(19);
      END_STATE();
    case 19:
      ACCEPT_TOKEN(sym_plain_scalar);
      if (lookahead == '/') ADVANCE(20);
      if ((!eof && set_contains(sym_plain_scalar_character_set_1, 12, lookahead))) ADVANCE(19);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(sym_plain_scalar);
      if ((!eof && set_contains(sym_plain_scalar_character_set_2, 13, lookahead))) ADVANCE(19);
      END_STATE();
    case 21:
      ACCEPT_TOKEN(sym_string);
      END_STATE();
    case 22:
      ACCEPT_TOKEN(sym_multiline);
      END_STATE();
    case 23:
      ACCEPT_TOKEN(sym_paren);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(sym_comment);
      if (lookahead != 0 &&
          lookahead != '\n' &&
          lookahead != '\r') ADVANCE(24);
      END_STATE();
    default:
      return false;
  }
}

static const TSLexMode ts_lex_modes[STATE_COUNT] = {
  [0] = {.lex_state = 0},
  [1] = {.lex_state = 0},
  [2] = {.lex_state = 8},
  [3] = {.lex_state = 8},
  [4] = {.lex_state = 8},
  [5] = {.lex_state = 8},
  [6] = {.lex_state = 8},
  [7] = {.lex_state = 8},
  [8] = {.lex_state = 8},
  [9] = {.lex_state = 8},
  [10] = {.lex_state = 8},
  [11] = {.lex_state = 8},
  [12] = {.lex_state = 0},
  [13] = {.lex_state = 0},
  [14] = {.lex_state = 0},
  [15] = {.lex_state = 0},
  [16] = {.lex_state = 0},
  [17] = {.lex_state = 0},
  [18] = {.lex_state = 0},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [anon_sym_LBRACE] = ACTIONS(1),
    [anon_sym_RBRACE] = ACTIONS(1),
    [anon_sym_LBRACK] = ACTIONS(1),
    [anon_sym_RBRACK] = ACTIONS(1),
    [anon_sym_COLON] = ACTIONS(1),
    [sym_identifier] = ACTIONS(1),
    [sym_id_reference] = ACTIONS(1),
    [sym_string] = ACTIONS(1),
    [sym_multiline] = ACTIONS(1),
    [sym_paren] = ACTIONS(1),
    [sym_comment] = ACTIONS(3),
  },
  [1] = {
    [sym_document] = STATE(16),
    [sym_map] = STATE(17),
    [anon_sym_LBRACE] = ACTIONS(5),
    [sym_comment] = ACTIONS(3),
  },
  [2] = {
    [sym_map] = STATE(3),
    [sym_vector] = STATE(3),
    [sym__value] = STATE(3),
    [sym_reserved] = STATE(3),
    [aux_sym_vector_repeat1] = STATE(3),
    [anon_sym_LBRACE] = ACTIONS(5),
    [anon_sym_LBRACK] = ACTIONS(7),
    [anon_sym_RBRACK] = ACTIONS(9),
    [sym_id_reference] = ACTIONS(11),
    [sym_plain_scalar] = ACTIONS(13),
    [sym_string] = ACTIONS(11),
    [sym_multiline] = ACTIONS(11),
    [sym_paren] = ACTIONS(15),
    [sym_comment] = ACTIONS(3),
  },
  [3] = {
    [sym_map] = STATE(4),
    [sym_vector] = STATE(4),
    [sym__value] = STATE(4),
    [sym_reserved] = STATE(4),
    [aux_sym_vector_repeat1] = STATE(4),
    [anon_sym_LBRACE] = ACTIONS(5),
    [anon_sym_LBRACK] = ACTIONS(7),
    [anon_sym_RBRACK] = ACTIONS(17),
    [sym_id_reference] = ACTIONS(19),
    [sym_plain_scalar] = ACTIONS(21),
    [sym_string] = ACTIONS(19),
    [sym_multiline] = ACTIONS(19),
    [sym_paren] = ACTIONS(15),
    [sym_comment] = ACTIONS(3),
  },
  [4] = {
    [sym_map] = STATE(4),
    [sym_vector] = STATE(4),
    [sym__value] = STATE(4),
    [sym_reserved] = STATE(4),
    [aux_sym_vector_repeat1] = STATE(4),
    [anon_sym_LBRACE] = ACTIONS(23),
    [anon_sym_LBRACK] = ACTIONS(26),
    [anon_sym_RBRACK] = ACTIONS(29),
    [sym_id_reference] = ACTIONS(31),
    [sym_plain_scalar] = ACTIONS(34),
    [sym_string] = ACTIONS(31),
    [sym_multiline] = ACTIONS(31),
    [sym_paren] = ACTIONS(37),
    [sym_comment] = ACTIONS(3),
  },
  [5] = {
    [ts_builtin_sym_end] = ACTIONS(40),
    [anon_sym_LBRACE] = ACTIONS(40),
    [anon_sym_RBRACE] = ACTIONS(40),
    [anon_sym_LBRACK] = ACTIONS(40),
    [anon_sym_RBRACK] = ACTIONS(40),
    [anon_sym_COLON] = ACTIONS(40),
    [sym_id_reference] = ACTIONS(40),
    [sym_plain_scalar] = ACTIONS(42),
    [sym_string] = ACTIONS(40),
    [sym_multiline] = ACTIONS(40),
    [sym_paren] = ACTIONS(40),
    [sym_comment] = ACTIONS(3),
  },
  [6] = {
    [sym_map] = STATE(15),
    [sym_vector] = STATE(15),
    [sym__value] = STATE(15),
    [sym_reserved] = STATE(15),
    [anon_sym_LBRACE] = ACTIONS(5),
    [anon_sym_LBRACK] = ACTIONS(7),
    [sym_id_reference] = ACTIONS(44),
    [sym_plain_scalar] = ACTIONS(46),
    [sym_string] = ACTIONS(44),
    [sym_multiline] = ACTIONS(44),
    [sym_paren] = ACTIONS(15),
    [sym_comment] = ACTIONS(3),
  },
  [7] = {
    [ts_builtin_sym_end] = ACTIONS(48),
    [anon_sym_LBRACE] = ACTIONS(48),
    [anon_sym_RBRACE] = ACTIONS(48),
    [anon_sym_LBRACK] = ACTIONS(48),
    [anon_sym_RBRACK] = ACTIONS(48),
    [anon_sym_COLON] = ACTIONS(48),
    [sym_id_reference] = ACTIONS(48),
    [sym_plain_scalar] = ACTIONS(50),
    [sym_string] = ACTIONS(48),
    [sym_multiline] = ACTIONS(48),
    [sym_paren] = ACTIONS(48),
    [sym_comment] = ACTIONS(3),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(54), 1,
      sym_plain_scalar,
    ACTIONS(52), 9,
      anon_sym_LBRACE,
      anon_sym_RBRACE,
      anon_sym_LBRACK,
      anon_sym_RBRACK,
      anon_sym_COLON,
      sym_id_reference,
      sym_string,
      sym_multiline,
      sym_paren,
  [18] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(58), 1,
      sym_plain_scalar,
    ACTIONS(56), 9,
      anon_sym_LBRACE,
      anon_sym_RBRACE,
      anon_sym_LBRACK,
      anon_sym_RBRACK,
      anon_sym_COLON,
      sym_id_reference,
      sym_string,
      sym_multiline,
      sym_paren,
  [36] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(62), 1,
      sym_plain_scalar,
    ACTIONS(60), 9,
      anon_sym_LBRACE,
      anon_sym_RBRACE,
      anon_sym_LBRACK,
      anon_sym_RBRACK,
      anon_sym_COLON,
      sym_id_reference,
      sym_string,
      sym_multiline,
      sym_paren,
  [54] = 3,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(66), 1,
      sym_plain_scalar,
    ACTIONS(64), 6,
      anon_sym_LBRACE,
      anon_sym_LBRACK,
      sym_id_reference,
      sym_string,
      sym_multiline,
      sym_paren,
  [69] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(68), 1,
      anon_sym_RBRACE,
    ACTIONS(70), 1,
      anon_sym_COLON,
    STATE(6), 1,
      sym_field,
    STATE(13), 2,
      sym_pair,
      aux_sym_map_repeat1,
  [86] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(70), 1,
      anon_sym_COLON,
    ACTIONS(72), 1,
      anon_sym_RBRACE,
    STATE(6), 1,
      sym_field,
    STATE(14), 2,
      sym_pair,
      aux_sym_map_repeat1,
  [103] = 5,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(74), 1,
      anon_sym_RBRACE,
    ACTIONS(76), 1,
      anon_sym_COLON,
    STATE(6), 1,
      sym_field,
    STATE(14), 2,
      sym_pair,
      aux_sym_map_repeat1,
  [120] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(79), 2,
      anon_sym_RBRACE,
      anon_sym_COLON,
  [128] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(81), 1,
      ts_builtin_sym_end,
  [135] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(83), 1,
      ts_builtin_sym_end,
  [142] = 2,
    ACTIONS(3), 1,
      sym_comment,
    ACTIONS(85), 1,
      sym_identifier,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(8)] = 0,
  [SMALL_STATE(9)] = 18,
  [SMALL_STATE(10)] = 36,
  [SMALL_STATE(11)] = 54,
  [SMALL_STATE(12)] = 69,
  [SMALL_STATE(13)] = 86,
  [SMALL_STATE(14)] = 103,
  [SMALL_STATE(15)] = 120,
  [SMALL_STATE(16)] = 128,
  [SMALL_STATE(17)] = 135,
  [SMALL_STATE(18)] = 142,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, SHIFT_EXTRA(),
  [5] = {.entry = {.count = 1, .reusable = true}}, SHIFT(12),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(2),
  [9] = {.entry = {.count = 1, .reusable = true}}, SHIFT(9),
  [11] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [13] = {.entry = {.count = 1, .reusable = false}}, SHIFT(3),
  [15] = {.entry = {.count = 1, .reusable = true}}, SHIFT(8),
  [17] = {.entry = {.count = 1, .reusable = true}}, SHIFT(10),
  [19] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [21] = {.entry = {.count = 1, .reusable = false}}, SHIFT(4),
  [23] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_vector_repeat1, 2, 0, 0), SHIFT_REPEAT(12),
  [26] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_vector_repeat1, 2, 0, 0), SHIFT_REPEAT(2),
  [29] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_vector_repeat1, 2, 0, 0),
  [31] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_vector_repeat1, 2, 0, 0), SHIFT_REPEAT(4),
  [34] = {.entry = {.count = 2, .reusable = false}}, REDUCE(aux_sym_vector_repeat1, 2, 0, 0), SHIFT_REPEAT(4),
  [37] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_vector_repeat1, 2, 0, 0), SHIFT_REPEAT(8),
  [40] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 2, 0, 0),
  [42] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_map, 2, 0, 0),
  [44] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [46] = {.entry = {.count = 1, .reusable = false}}, SHIFT(15),
  [48] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_map, 3, 0, 0),
  [50] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_map, 3, 0, 0),
  [52] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_reserved, 1, 0, 0),
  [54] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_reserved, 1, 0, 0),
  [56] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_vector, 2, 0, 0),
  [58] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_vector, 2, 0, 0),
  [60] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_vector, 3, 0, 0),
  [62] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_vector, 3, 0, 0),
  [64] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_field, 2, 0, 0),
  [66] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_field, 2, 0, 0),
  [68] = {.entry = {.count = 1, .reusable = true}}, SHIFT(5),
  [70] = {.entry = {.count = 1, .reusable = true}}, SHIFT(18),
  [72] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [74] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2, 0, 0),
  [76] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_map_repeat1, 2, 0, 0), SHIFT_REPEAT(18),
  [79] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_pair, 2, 0, 0),
  [81] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [83] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_document, 1, 0, 0),
  [85] = {.entry = {.count = 1, .reusable = true}}, SHIFT(11),
};

#ifdef __cplusplus
extern "C" {
#endif
#ifdef TREE_SITTER_HIDE_SYMBOLS
#define TS_PUBLIC
#elif defined(_WIN32)
#define TS_PUBLIC __declspec(dllexport)
#else
#define TS_PUBLIC __attribute__((visibility("default")))
#endif

TS_PUBLIC const TSLanguage *tree_sitter_plan(void) {
  static const TSLanguage language = {
    .version = LANGUAGE_VERSION,
    .symbol_count = SYMBOL_COUNT,
    .alias_count = ALIAS_COUNT,
    .token_count = TOKEN_COUNT,
    .external_token_count = EXTERNAL_TOKEN_COUNT,
    .state_count = STATE_COUNT,
    .large_state_count = LARGE_STATE_COUNT,
    .production_id_count = PRODUCTION_ID_COUNT,
    .field_count = FIELD_COUNT,
    .max_alias_sequence_length = MAX_ALIAS_SEQUENCE_LENGTH,
    .parse_table = &ts_parse_table[0][0],
    .small_parse_table = ts_small_parse_table,
    .small_parse_table_map = ts_small_parse_table_map,
    .parse_actions = ts_parse_actions,
    .symbol_names = ts_symbol_names,
    .symbol_metadata = ts_symbol_metadata,
    .public_symbol_map = ts_symbol_map,
    .alias_map = ts_non_terminal_alias_map,
    .alias_sequences = &ts_alias_sequences[0][0],
    .lex_modes = ts_lex_modes,
    .lex_fn = ts_lex,
    .primary_state_ids = ts_primary_state_ids,
  };
  return &language;
}
#ifdef __cplusplus
}
#endif
