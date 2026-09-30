/**
 * tree-sitter-plan — Plan DSL v1 grammar.
 *
 * Mirrors the Instaparse EBNF in resources/plan/grammar.bnf. Node names match the
 * Clojure lossless CST (see src/plan/cst.clj) so both parsers name the same
 * concepts: document map pair field vector identifier plain_scalar string
 * multiline comment reserved paren. Whitespace and commas are trivia (extras) and are not
 * named nodes; comment is a named extra so it can be highlighted.
 *
 * This grammar performs no semantic validation: it accepts DSL v1 reserved forms
 * (parenthesised expressions) as `reserved`, and it is the
 * Clojure analysis pipeline — never this grammar — that decides whether a form is
 * allowed (e.g. the syntax/reserved diagnostic). The two parsers are not compared
 * for isomorphic trees; Clojure remains the sole authority for semantics and IR.
 */

module.exports = grammar({
  name: 'plan',

  // Trivia: whitespace and commas are insignificant separators; comments are a
  // named node so treesit can colour them. Instaparse keeps these as sibling
  // trivia; tree-sitter models them as extras.
  extras: $ => [
    /[ \t\r\n]+/,
    ',',
    $.comment,
  ],

  rules: {
    // document = trivia* map trivia*  (leading/trailing trivia handled by extras)
    document: $ => $.map,

    // map = '{' (trivia | pair)* '}'
    map: $ => seq('{', repeat($.pair), '}'),

    // vector = '[' (trivia | value)* ']'
    vector: $ => seq('[', repeat($._value), ']'),

    // pair = field value
    pair: $ => seq($.field, $._value),

    // field = ':' identifier
    field: $ => seq(':', $.identifier),

    // value = map | vector | string | multiline | reserved | plain_scalar
    _value: $ => choice(
      $.map,
      $.vector,
      $.string,
      $.multiline,
      $.reserved,
      $.id_reference,
      $.plain_scalar,
    ),

    identifier: _ => /[a-z][a-z0-9]*(?:-[a-z0-9]+)*/,

    id_reference: _ => token(new RegExp(
      '@(?:[^\\s,{}\\[\\]"`\\\\:();/@]+|/[^/*\\s,{}\\[\\]"`\\\\:();@][^\\s,{}\\[\\]"`\\\\:();/@]*)*/?',
    )),

    plain_scalar: _ => token(new RegExp(
      '(?:[^\\s,{}\\[\\]"`\\\\:();/@#\\x27~^]+|/[^/*\\s,{}\\[\\]"`\\\\:();@#\\x27~^][^\\s,{}\\[\\]"`\\\\:();/@#\\x27~^]*)(?:/[^/*\\s,{}\\[\\]"`\\\\:();@#\\x27~^][^\\s,{}\\[\\]"`\\\\:();/@#\\x27~^]*)*/?|/',
    )),

    string: _ => /"(?:\\.|[^"\\\r\n])*"/,

    multiline: _ => /`[^`\\]*(?:\\.[^`\\]*)*`/,

    // Parenthesised expressions are accepted syntactically and diagnosed by Clojure.
    reserved: $ => $.paren,

    paren: _ => token(seq('(', /[^()]*/, ')')),

    // comment = '//' rest-of-line
    comment: _ => token(seq('//', /[^\r\n]*/)),
  },
});
