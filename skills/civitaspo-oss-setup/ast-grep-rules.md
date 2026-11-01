# ast-grep rule candidates

Use these candidates as a starting point for each language the user selected. Implement the rules that fit the project's runtime and APIs; adapt call shapes and imports to the actual code. For other supported languages, select comparable documented risky APIs rather than copying patterns from another language. Include applicable rules even when the initial repository has no matching code.

| Language | Candidate | Scope and remediation |
| --- | --- | --- |
| JavaScript / TypeScript | Direct `eval` and `Function` construction | Review dynamic code execution; avoid executing strings as code. Match actual call forms, accounting for shadowed names. [MDN: eval](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval) |
| JavaScript / TypeScript | `innerHTML` assignment and `insertAdjacentHTML` | For browser code, review HTML injection sinks; prefer `textContent` for plain text or correctly sanitized trusted HTML. Do not flag `textContent`. [MDN: innerHTML](https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML) |
| Python | `eval` and `exec` | Review dynamic code execution; account for shadowed names and intentional trusted input. [Python built-ins](https://docs.python.org/3/library/functions.html#eval) |
| Python | `pickle.load` and `pickle.loads` | Review deserialization boundaries; never unpickle data from an untrusted or tampered source. Match the project's imports and aliases. [Python pickle](https://docs.python.org/3/library/pickle.html) |
| Python | `subprocess` calls with `shell=True` | Review shell command construction; keep ordinary argument-list calls out of this rule. [Python subprocess](https://docs.python.org/3/library/subprocess.html#security-considerations) |
| Go | `tls.Config` with `InsecureSkipVerify: true` | Review disabled certificate verification. Custom verification and tests can be intentional; account for import aliases. [Go crypto/tls](https://pkg.go.dev/crypto/tls#Config) |
| Go | `exec.Command` invoking `sh -c` or equivalent | Review shell command construction; do not flag ordinary argument-vector calls. [Go os/exec](https://pkg.go.dev/os/exec) |
| Go | SQL assembled directly in database query arguments | Review concatenation or formatting at the project's database API calls; use parameters for values. Do not flag parameterized queries. [Go database queries](https://go.dev/doc/database/querying) |
| Rust | `Command` invoking `sh -c` or equivalent | Review shell command construction; do not flag ordinary argument-vector calls. [Rust Command](https://doc.rust-lang.org/std/process/struct.Command.html) |
| Rust | `unsafe` blocks and declarations | Optionally inventory unsafe code for review of its invariants; do not treat every use as a defect. [Rust unsafe](https://doc.rust-lang.org/reference/unsafe-keyword.html) |

These patterns identify syntax, not whether input is attacker-controlled or sanitized. They cannot resolve every alias or replace dataflow analysis, a dedicated secret scanner, or language-specific security tools. API names alone can also match unrelated functions. Check the project's actual imports, syntax and trust boundaries before making a rule blocking. Start context-dependent findings as warnings; promote a rule to `error` only when the project can enforce it with narrow, explained exceptions. Use separate, focused rules with actionable messages.

For every committed rule, test matching examples and safe near misses, including relevant aliases and exceptions. Run [ast-grep test](https://ast-grep.github.io/guide/test-rule.html) in the project's test task. Do not add automatic rewrites for security-sensitive findings without reviewing their semantics.
