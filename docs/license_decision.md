# License Decision

> **Status: decision pending.** This records the current legal state and a recommendation. It does not grant a license. Only a committed root `LICENSE` file plus matching notices will enact the choice.

## Current state

The repository has no `LICENSE` file and GitHub reports no detected license. Default copyright therefore applies: the copyright holder retains rights, while GitHub's Terms allow public viewing and forking through GitHub's service. Public visibility alone does not make the project open source.

## Recommendation

Use **GNU GPL-3.0-or-later** for the Godot game code and other original software in this repository.

Why it fits:

- people may use, study, change, distribute, and commercially sell the software;
- distributed modified versions must preserve the license and make corresponding source available;
- it supports the project's transparent-development goal better than MIT or Apache, which permit closed proprietary forks;
- it does not prevent Patreon funding, paid builds, commissions, or selling the game.

When a networked voting/metrics service is created, keep it in a clearly separated `server/` component under **GNU AGPL-3.0-or-later**. AGPL adds the requirement to offer corresponding source when a modified version is operated for users over a network, which ordinary GPL does not generally trigger.

For the first licensing pass, keep original docs, data, and project-created art under GPL too. This makes boundaries easy to understand. A later deliberate split may offer original documentation and standalone art under **CC BY-SA 4.0**, but Creative Commons recommends software-specific licenses for code. Do not add that complexity until asset ownership and reuse goals are settled.

## Explicit exclusions and notices

The project license can cover only material the project has the right to license. Third-party fonts, emoji font files, libraries, sounds, and contributed assets retain their own terms and must be listed in a root `THIRD_PARTY_NOTICES.md` or equivalent. Unicode emoji characters used as text are not a claim of ownership over any platform's rendered glyph artwork.

Before accepting outside contributions, add `CONTRIBUTING.md` and choose a lightweight provenance rule such as the Developer Certificate of Origin. Contributors need to understand that submitted work is licensed under the repository's applicable license.

## Alternatives considered

- **MIT/Apache-2.0:** simple and highly reusable, but permit closed commercial forks. Not recommended for the stated “keep improvements open” goal.
- **MPL-2.0:** file-level copyleft and easier proprietary integration, but weaker protection for a complete game fork.
- **AGPL-3.0-or-later for everything:** valid, but the network clause adds little to a downloadable client. Better reserved for the service where it matters.
- **NonCommercial terms:** may protect commercial exclusivity but are not open-source licenses and complicate community reuse. Not recommended unless commercial restriction is more important than calling the project open source.

## Sources

- [GitHub: Licensing a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
- [GNU: Why the Affero GPL](https://www.gnu.org/licenses/why-affero-gpl.html)
- [Creative Commons FAQ: software and CC licenses](https://creativecommons.org/faq/#can-i-apply-a-creative-commons-license-to-software)

This is practical project guidance, not legal advice. If ownership, adult-content distribution, contributor agreements, or commercial exclusivity becomes material, obtain advice from a qualified lawyer in the relevant jurisdictions.
