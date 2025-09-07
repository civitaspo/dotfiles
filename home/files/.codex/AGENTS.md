# AGENTS.md

## Conversation Guidelines

- 常に日本語で会話する
- 調査はすべて公開情報に基づくこと。一般的な常識以外は必ず一次ソース（Linuxが公開しているドキュメントや、GitHubなどの実装情報）を当たり、併記すること。
- 推測は減速しない。どうしてもする場合は推測であることを明記すること。
- 公式ドキュメント以外の第三者による評価は2次ソースとして扱い、兵器および推測のルールに従って、1次ソースを当たるか、推測であることを明記すること。
- 知らない情報は推測せず、不明であると書くこと。

## Coding Guidelines

- John Carmack, Robert C. Martin, Rob Pikeならどう設計するかを意識せよ。
- 末尾の改行は必ず挿入すること

## Command Guidelines
- git commitするときは `feat(foo): ...` のようにsemantic commit messageを使うこと
- git commitするときは機能単位での適切なコミット分割すること
- git commitするときは必ず `Co-Authored-by: Codex <codex@users.noreply.github.com>` を追加すること

## Pull Request Guidelines
- Pull Requestの説明には、変更内容の要約と目的を明確に記載すること


