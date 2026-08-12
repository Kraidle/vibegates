# Pathologies of Vibe-Coded Products — a documented survey

**Status**: v1.0 (English edition, 2026-08-12), derived from a French-language corpus built and source-verified the same year.
**Companion**: [02-framework.md](02-framework.md) derives one enforceable countermeasure from every pathology below.

**Rigor conventions**
- Every quantitative claim carries its reference (§9, bibliography).
- **[preprint]** = not peer-reviewed; treated as converging evidence, never as sole proof.
- **[grey]** = industry literature; the publisher's conflict of interest (COI) is named.
- Verification levels: **[read]** full text or methods/results read · **[abs]** primary abstract read (terminal only when every claim used appears in it) · **[2nd]** secondary corroboration — never terminal; a naked [2nd] is a defect.

---

## 1. Framing

### 1.1 Definition

"Vibe coding" was coined in February 2025 by Andrej Karpathy: giving in to the vibes, forgetting the code exists — intent expressed in natural language, code generated and modified **without review or careful scrutiny**. The reference grey-literature review (101 practitioner sources, 518 first-hand accounts) defines it as relying on AI code generation "through intuition and trial-and-error without necessarily understanding the underlying code" [Vibe-GLR 2025] [abs].

The operative demarcation is Simon Willison's: if an LLM wrote every line but you reviewed, tested and understood it all, that is not vibe coding — that is using an LLM as a typing assistant [Willison 2025]. Vibe coding is defined by **the absence of verification**, not by the use of AI. That absence produces every pathology below.

### 1.2 What this document does not claim

Not that generative AI necessarily degrades software. It establishes that the **unverified output** of these tools carries measured, systematic defects with a signature of their own — and that verification is precisely what vibe coding removes.

### 1.3 Survey methodology

- **Nature**: a targeted narrative review — not a full systematic literature review in the Kitchenham & Charters sense. Declared, not hidden: the goal is an enforceable state of the art, not a meta-analysis.
- **Corpus construction**: iterative web search (2026), one query family per pathology family, followed by reading of the load-bearing primary sources; paywalled items acquired or closed by documented academic substitution.
- **Inclusion**: peer-reviewed primary studies first; grey literature admitted only where it contributes volume without academic equivalent (e.g. GitClear's 211M/623M changed lines), always with COI named; preprints as converging evidence only.
- **Threats to this review's own validity**: (a) selection bias — searches were pathology-oriented; compensated by §8, built by searching for contrary results; (b) measurement heterogeneity — no numeric aggregation attempted; (c) young literature — key results are flagged preprints; (d) anglophone coverage bias.
- **Verification discipline** (measured lesson from this corpus's own construction): primary reading corrected four figures that secondary summaries reported wrongly — a duplication "×8" that is actually ×4 in block frequency, an unsourced "15–50 % more defects" claim (removed), a yearly churn series not found in the primary (replaced), a misattributed "volume-quality law" (removed). Engraved rule: **no number enters a document on the strength of a secondary summary.**

---

## 2. Code pathologies

### 2.1 Intrinsic insecurity, flat over time

- **Pearce et al. 2022** (IEEE S&P) [abs]: 89 scenarios from MITRE's CWE Top-25 territory, 1,689 Copilot-generated programs, **≈ 40 % vulnerable**; three analysis axes (weakness, prompt, domain diversity) [Pearce 2022].
- **Veracode 2025** [read] [grey — AppSec vendor]: 80 completion tasks (4 CWEs × 4 languages × 5 instances: SQL injection CWE-89, XSS CWE-80, log injection CWE-117, weak crypto CWE-327) given to 100+ LLMs, SAST-judged. **45 % of tasks produce the vulnerable variant.** Security pass rates by language: Python 61.7 %, JavaScript 57.3 %, C# 55.3 %, **Java 28.5 %**. By CWE: crypto 85.6 % and SQLi 80.4 % (decent, improving) — but **XSS 13.5 %** and **log injection 12.0 %**, poor and degrading. Model size has virtually no effect (50.6–51.1 % across size classes), and security is **flat over time** while syntactic correctness approaches perfection. Declared threat to validity: functional correctness not checked (compilation + SAST only); a manual sample check found no material effect [Veracode 2025].

Three years separate the two measurements; the insecurity rate is stationary. Product security therefore rests entirely on downstream verification — the step vibe coding omits.

### 2.2 Assistance degrades the assisted human's code too

**Perry et al. 2023** (ACM CCS) [read]: controlled study, 47 retained participants (33 with a codex-davinci-002-based assistant, 14 control), five security tasks in Python, JavaScript and C, double-blind manual grading (inter-rater κ 0.68–0.96), logistic regressions with Benjamini–Hochberg correction. The assisted group wrote less secure code on **four of five tasks** — e.g. ECDSA signing: 3 % secure vs 21 % control (p = 0.039), dominant error an unsafe randomness source inherited from the AI-chosen library; path confinement: 12 % vs 29 %, mishandled symlinks (p = 0.019). Effects on the C task were mixed. The assisted group also **believed** its code more secure [Perry 2023].

Two second-order lessons visible only in the full text:
1. Participants routinely accepted AI output **without further security verification once their correctness tests passed** — functional correctness served as an illegitimate proxy for security.
2. Participants who trusted the assistant least and **reworked their prompts** produced fewer vulnerabilities: vigilance is the measured moderator — the exact inverse of the vibe-coding posture.

### 2.3 Demonstrated inability to refactor safely

**CodeScene 2024** [read] [grey — code-health vendor]: Tornhill, Borg & Mones. 100,000+ real code smells (JS/TS, four families), correctness judged by running existing test suites plus code-health rescoring. Valid refactorings: PaLM 2 code **37.29 %**, PaLM 2t 34.73 %, GPT-3.5 **30.26 %**, phind-codellama-34B 18.14 % — output is ~100 % syntactically valid yet breaks behavior in the majority of attempts; GPT-4 marginally better at an order of magnitude more cost. Error catalogue: silently dropped branches (a security threat when input validation goes), inverted boolean logic (`a && b` → `!(a && b)`), and mistreated JavaScript `this` on function extraction. The paper stresses these failures are "subtle and not obvious to the human eye during a code inspection" — review alone is insufficient; tests are mandatory (→ framework, G2+G3 coupling). The decisive counter-result: a **fact-checking layer** that rejects unvalidated proposals raises retained refactorings to **98 % correctness** [CodeScene 2024].

Consequence: a vibe-coded product cannot be *healed* by the tool that produced it without external verification. The generator is not a repair tool.

### 2.4 Defects in the wild, and their survival

**[preprint] [abs]** Across 302,600 verified AI-authored commits in 6,299 GitHub repositories (five assistants), before/after static analysis attributes **484,000+ distinct issues** to AI changes — 89.3 % code smells, the rest correctness and security defects; **more than 15 % of each assistant's commits introduce at least one issue**, and **22.7 % of AI-introduced issues survive to the latest repository version** [Debt-Boom 2026]. That last figure links code pathology directly to debt (§4): a substantial share of vibe-coded defects will never be fixed.

---

## 3. Architectural pathologies

### 3.1 No global design

Vibe coding proceeds by local accretion: each prompt optimizes immediate satisfaction of an intent with no view of the system. The classical frame applies directly:

- **Lehman** [read — Table I, p. 1068]: five laws of program evolution from quantitative studies. Law I (*Continuing Change*): a used program changes continually or becomes progressively less useful. Law II (*Increasing Complexity*): an evolving program's complexity, reflecting deteriorating structure, **increases unless work is done to maintain or reduce it**. Context figure: ~70 % of 1977 US software expenditure already went to maintenance [Lehman 1980]. Vibe coding maximizes Law-I change volume while deleting the counter-work Law II demands.
- **Parnas, *Software Aging*** [read]: two distinct causes — failure to adapt, and "**ignorant surgery**": changes made by someone who does not understand the original design concept, inconsistent with it, invalidating it, until "nobody understands the modified product" [Parnas 1994]. A statistical generator with no memory of the design intent is the ignorant surgeon in pure form — and vibe coding also removes the second pair of eyes Parnas prescribed.
- **Foote & Yoder, *Big Ball of Mud*** [read]: the default architecture of any system without a counter-force is mud structured by expedience; seven forces push there (time, cost, experience, skill, visibility, complexity, change) [Foote 1997]. Vibe coding industrializes expedience.

### 3.2 Measured erosion: duplication up, refactoring collapsed

**GitClear 2025–2026** [read] [grey — analytics vendor] — two reports read in primary; 211M changed lines (2020–2024) and 623M changes (2023–2026):

- **Cloned code**: 8.3 % → **12.3 %** of changed lines (2021–2024; "4× more code cloning" in block frequency) [GitClear 2025]; duplicated blocks 40.3 → **73.0 per million changed lines** 2023–2026 (**+81 %**) [GitClear 2026].
- 2024 was the **first year intra-commit copy/paste exceeded moved (refactored) code** [GitClear 2025]; copy/paste rose 9.4 % (2022) → **15.7 %** (H1 2026) [GitClear 2026].
- Moved/refactored code: ~25 % of changed lines (2021) → under 10 % (2024) → **3.8 %** (2026 YTD) — roughly a five-fold copy-paste preference vs the pre-AI baseline [GitClear 2025–2026].
- The 2026 report names block duplication as the risk signal academic literature ties most directly to defects, without quantifying — so no surplus-defect figure is repeated here.

Duplication is vibe coding's architectural signature: the generator does not know the existing code, so it re-creates it. Abstraction is precisely the act local generation never performs.

### 3.3 Silent decision drift

A vibe-coded product has no ADRs [Nygard 2011] [read], no threat model, no architecture description in the ISO/IEC/IEEE 42010 sense [read — clause 6]. Its "decisions" are implicit in model outputs and change from prompt to prompt. The architecture is not bad; it is **indeterminate** — which is worse, because conformance to a nowhere-stated intent cannot be audited.

---

## 4. Technical debt

### 4.1 Measured accumulation

- **Churn** (code rewritten <2 weeks after commit): **+15 %** in 2026 YTD vs the 2023–2026 window [GitClear 2026] [read] [grey]. Churn is discarded work — correction-debt paid immediately, in growing volume.
- **Defect survival**: 22.7 % of AI-introduced issues persist to latest version (§2.4) [Debt-Boom 2026] [preprint] — a direct measure of unpaid debt.
- **[preprint] [abs]** Across 477 repositories (159 LLM / 159 ML / 159 non-ML), LLM projects accumulate self-admitted technical debt at ML-like rates (3.95 % vs 4.10 %) but stay debt-free **2.4× longer** (median 492 vs 204 days) before rapid accumulation — a "delayed but persistent" pattern, with three LLM-specific debt categories identified [SATD-LLM 2026].

### 4.2 The nature of vibe-coded debt: never contracted, so never repayable

The canonical frame treats debt as a **loan** someone knowingly took and can plan to repay. Cunningham [read]: shipping not-quite-right code is borrowing, useful if repaid promptly by rewrite — every minute on such code is interest, and whole organizations can be brought to a standstill under unconsolidated implementation debt [Cunningham 1992]. Fowler [read] crosses deliberate/inadvertent with prudent/reckless: the only virtuous quadrant is **deliberate-prudent** debt, repaid early; inadvertent-reckless debt exacts "crippling interest" [Fowler 2009]. Kruchten, Nord & Ozkaya [read] add the management layer: a **technical-debt landscape** where architectural and structural debt is *mostly invisible*, explicit management through a **debt-item backlog** in release planning — and a warning central to this framework: equating debt with what static analyzers detect leaves aside structural and architectural debt, which tools cannot see [Kruchten 2012].

Vibe-coded debt sits outside this frame: **inadvertent and reckless at industrial scale**. Nobody contracted it, nobody knows the principal, nobody knows where it lives, and the generator writes no honest SATD about its own shortcuts. Debt without a creditor or schedule can only be managed by preventing it from entering — which is what the gates do.

### 4.3 The productivity illusion that finances it

**METR 2025** [abs] (RCT: 16 experienced OSS developers, ~5 years on their own repos, 246 real tasks, task-level randomization, Cursor Pro + frontier models): tasks took **19 % longer** with AI — while developers forecast −24 %, estimated −20 % afterwards, and consulted experts forecast −38/−39 %. The authors acknowledge experimental artifacts cannot be fully excluded but report the slowdown robust across analyses; METR labels the result historical (early-2025 tooling) [METR 2025]. What matters for this framework is not the sign but the **39-point gap between perception and measurement**, shared by practitioners and experts alike. Hence Principle P1: measure, never impressions.

---

## 5. Supply chain

### 5.1 Package hallucination and slopsquatting

**Spracklen et al., USENIX Security 2025** [read]: 576,000 samples, 16 LLMs, Python and JavaScript — **19.7 % of suggested packages do not exist** (205,474 unique fictitious names); commercial models 5.2 %, open models 21.7 %; Python 15.8 %, JavaScript 21.3 %. Decisive for security: hallucinations are **systematic, not random** — 43 % of hallucinated names recur in all 10 repetitions of the same query, ~58 % recur repeatedly [Spracklen 2025]. That predictability grounds the **slopsquatting** attack class: register the hallucinated package with a payload and wait. The authors show mitigations cut the rate substantially — mitigations that presuppose exactly the verification step vibe coding omits. An operator who runs `npm install` / `pip install` on the model's word hands the attacker the cheapest entry point.

### 5.2 No SBOM, no provenance

Vibe-coded products ship with no software bill of materials and no provenance record (which model, version, prompt, context produced which artifact). Baseline frameworks — NIST SSDF SP 800-218 and its generative-AI companion SP 800-218A [NIST 2024], SLSA for build integrity — treat provenance as table stakes. The gap is not a missing refinement; it is the inability to answer "where did this code come from?".

---

## 6. Compliance

### 6.1 Intellectual property and licenses

- *Doe v. GitHub* (filed Nov. 2022) charges that Copilot reproduces training code **without attribution, copyright notice, or license** — obligations of nearly every open-source license. Direct-infringement claims were dismissed in 2023 for want of identified verbatim reproductions; DMCA §1202 and contract claims survived into appeal [Doe-GitHub].
- The operational risk is the "**copyleft surprise**": a generated snippet functionally identical to GPL code enters a proprietary product and carries the copyleft obligation with it [DeVault 2022]. Vibe coding institutionalizes the risk: with no provenance, no one can detect the snippet or prove non-contamination.

### 6.2 Regulation (EU as the leading example)

- **AI Act (EU 2024/1689)**: high-risk obligations from 2 Aug 2026 — technical documentation, logs, human oversight, risk management. When a vibe-coded component enters a high-risk system, these obligations flow up to an organization that cannot meet them without provenance or documentation [EU-AIA].
- **Cyber Resilience Act (EU 2024/2847)**: exploited-vulnerability reporting from 11 Sep 2026; full conformity for products with digital elements by end-2027 — secure by design/default, vulnerability handling, security updates for **at least 5 years** [EU-CRA]. A product whose generated code fails security 45 % of the time at the model's mouth, with no SBOM or verification process, cannot support a CRA conformity declaration.
- The revised **Product Liability Directive** extends liability to software and lets regulatory non-conformity feed a presumption of defectiveness [Freshfields-PLD].

The common pattern: these texts all demand what vibe coding removes — documentation, traceability, verification, human oversight. **Non-compliance is not an accident of vibe coding; it is its definition in regulatory language.**

---

## 7. The human factor

Three documented mechanisms make vibe coding self-sustaining:

1. **Measured overconfidence**: the AI-assisted group believes itself more secure while being less so [Perry 2023].
2. **Measured speed illusion**: a 39-point gap between perceived gain and measured effect [METR 2025].
3. **Material disengagement**: qualitative work describes operators orchestrating production they no longer touch, with selective oversight [Vibe-GLR 2025; Good-Vibrations 2025].

Consequence: no rule that relies on the operator's spontaneous judgment ("I verify when it feels risky") can hold, because that judgment's calibration is precisely what is shown broken. The gates are therefore **structural and non-discretionary**.

---

## 8. Counter-evidence and discussion

A prosecution brief is not proof. This section was built by searching for results **contrary** to §§2–7.

### 8.1 Speed gains are real and measured

**Peng et al. 2023** [abs] (controlled experiment; authors affiliated with Microsoft/GitHub — COI noted): recruited developers implementing an HTTP server in JavaScript finished **55.8 % faster** with Copilot (95 % CI 21–89 %), with the largest gains for the least experienced [Peng 2023]. Solid in its regime — **a single, green-field, short, self-contained task** scored on completion speed, with no maintenance, review, or integration requirement. Not in contradiction with METR (real tasks on mature repos, opposite sign): together they bracket the phenomenon. Gains are real where required context is thin; they invert where understanding the existing system dominates. Vibe coding's error is generalizing the first regime to the second.

### 8.2 DORA 2024: the damage is at integration

Process metrics improve with AI adoption (code quality, complexity, review and approval speed), yet delivery stability and throughput fall (−7.2 % / −1.5 % per +25 pts adoption; 89 % uncertainty intervals), and **product performance shows no association** (+0.2 %, n.s.) while organizational (+2.3 %) and team (+1.4 %) performance rise — "high-performing teams use AI, but products don't seem to benefit." DORA's own hypothesis: AI grows changelists, and large changes are slower and more instability-prone; nothing replaces "the basics — small batch sizes and robust testing." The report also warns that faster reviews may reflect **over-reliance on AI**, not better review [DORA 2024] [read pp. 38–43]. This localizes the damage (integration and delivery, not typing) and directly grounds rule R-25 (bounded batch size) and an anti-metric (review speed is never maximized).

### 8.3 What the discussion establishes

Speed benefits exist in thin-context regimes. The pathologies of §§2–7 are not contradicted by those results: they live precisely in the dimensions the positive studies do not measure — security, maintenance, delivery stability, compliance. The framework therefore does not ban the tool; it **prices verification at the point where it is cheapest** (a validation layer turns 37 % correct refactorings into 98 % — §2.3) and bounds the regimes where losses are documented.

---

## 9. Bibliography

Peer-reviewed / primary:

- **[Pearce 2022]** [abs] Pearce, Ahmad, Tan, Dolan-Gavitt, Karri. *Asleep at the Keyboard? Assessing the Security of GitHub Copilot's Code Contributions.* IEEE S&P 2022. [arXiv:2108.09293](https://arxiv.org/abs/2108.09293)
- **[Perry 2023]** [read] Perry, Srivastava, Kumar, Boneh. *Do Users Write More Insecure Code with AI Assistants?* ACM CCS 2023, pp. 2785–2799. [DOI 10.1145/3576915.3623157](https://dl.acm.org/doi/10.1145/3576915.3623157)
- **[Peng 2023]** [abs] Peng, Kalliamvakou, Cihon, Demirer. *The Impact of AI on Developer Productivity: Evidence from GitHub Copilot.* 2023. [arXiv:2302.06590](https://arxiv.org/abs/2302.06590) — COI: Microsoft/GitHub authorship.
- **[Spracklen 2025]** [read] Spracklen, Wijewickrama, Sakib, Maiti, Viswanath, Jadliwala. *We Have a Package for You! A Comprehensive Analysis of Package Hallucinations by Code Generating LLMs.* USENIX Security 2025. [arXiv:2406.10279](https://arxiv.org/abs/2406.10279)
- **[METR 2025]** [abs] Becker et al. *Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity.* [arXiv:2507.09089](https://arxiv.org/abs/2507.09089)
- **[Vibe-GLR 2025]** [abs] *Vibe Coding in Practice: Motivations, Challenges, and a Future Outlook — a Grey Literature Review.* ICSE-SEIP 2026. [arXiv:2510.00328](https://arxiv.org/abs/2510.00328)
- **[Good-Vibrations 2025]** [2nd → under watch] *Good Vibrations? A Qualitative Study of Co-Creation, Communication, Flow, and Trust in Vibe Coding.* [arXiv:2509.12491](https://arxiv.org/abs/2509.12491)
- **[Bacchelli 2013]** [read] Bacchelli, Bird. *Expectations, Outcomes, and Challenges of Modern Code Review.* ICSE 2013 — 17 developers observed across 16 teams, 570 review comments classified, 165 managers + 873 programmers surveyed. [author PDF](https://sback.it/publications/icse2013.pdf)
- **[McIntosh 2014]** [read] McIntosh, Kamei, Adams, Hassan. *The Impact of Code Review Coverage and Code Review Participation on Software Quality (Qt, VTK, ITK).* MSR 2014 — low review coverage ≈ up to **2** extra post-release defects per component; low participation ≈ up to **5**. [DOI 10.1145/2597073.2597076](https://doi.org/10.1145/2597073.2597076)
- **[Fagan 1976]** [read] Fagan. *Design and Code Inspections to Reduce Errors in Program Development.* IBM Systems Journal 15(3), pp. 182–211 — exit-criteria inspections: **+23 %** coding productivity (control-sample delta 0.9 %, n.s.), **38 % fewer errors** than walk-throughs; negative-yield inspection I3 dropped.
- **[Jia 2011]** [read] Jia, Harman. *An Analysis and Survey of the Development of Mutation Testing.* IEEE TSE 37(5), pp. 649–678 — mutation score as test-adequacy criterion; 390+ papers surveyed; maturity concluded.
- **[Lehman 1980]** [read] Lehman. *Programs, Life Cycles, and Laws of Software Evolution.* Proc. IEEE 68(9), pp. 1060–1076.
- **[Parnas 1994]** [read] Parnas. *Software Aging.* ICSE-16, pp. 279–287.
- **[Foote 1997]** [read] Foote, Yoder. *Big Ball of Mud.* PLoP '97; PLoPD4 ch. 29. [text](http://www.laputan.org/mud/)
- **[Cunningham 1992]** [read] Cunningham. *The WyCash Portfolio Management System.* OOPSLA '92. [text](http://c2.com/doc/oopsla92.html)
- **[Fowler 2009]** [read] Fowler. *Technical Debt Quadrant.* [post](https://martinfowler.com/bliki/TechnicalDebtQuadrant.html)
- **[Kruchten 2012]** [read] Kruchten, Nord, Ozkaya. *Technical Debt: From Metaphor to Theory and Practice.* IEEE Software 29(6), pp. 18–21.
- **[Nygard 2011]** [read] Nygard. *Documenting Architecture Decisions.* [post](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- **[ISO 42010]** [read — clause 6 in extenso] ISO/IEC/IEEE 42010:2022, *Software, systems and enterprise — Architecture description.*

Grey **[grey]** and preprints **[preprint]**:

- **[Veracode 2025]** [read pp. 1–14] *2025 GenAI Code Security Report.* COI: AppSec vendor. [PDF](https://www.veracode.com/wp-content/uploads/2025_GenAI_Code_Security_Report_Final.pdf)
- **[GitClear 2025]** [read] *AI Copilot Code Quality: 2025 Data Suggests 4x Growth in Code Clones.* COI: analytics vendor. [link](https://www.gitclear.com/ai_assistant_code_quality_2025_research)
- **[GitClear 2026]** [read] *The Maintainability Gap: 2026 AI Code Quality Research.* [link](https://www.gitclear.com/the_ai_code_quality_maintainability_gap)
- **[CodeScene 2024]** [read] Tornhill, Borg, Mones. *Refactoring vs. Refuctoring.* COI: code-health vendor. [research index](https://codescene.com/resources/research-and-insights)
- **[DORA 2024]** [read pp. 38–43] *Accelerate State of DevOps Report 2024* (v. 2024.3). COI: Google (runs against the negative finding reported). [PDF](https://dora.dev/research/2024/dora-report/2024-dora-accelerate-state-of-devops-report.pdf)
- **[SATD-LLM 2026]** [abs] [preprint] Selvanayagam, Ghaleb, Abdellatif. *Self-Admitted Technical Debt in LLM Software.* [arXiv:2601.06266](https://arxiv.org/abs/2601.06266)
- **[Debt-Boom 2026]** [abs] [preprint] *Debt Behind the AI Boom: A Large-Scale Empirical Study of AI-Generated Code in the Wild.* [arXiv:2603.28592](https://arxiv.org/abs/2603.28592)

Legal / regulatory:

- **[Doe-GitHub]** *Doe v. GitHub, Microsoft, OpenAI.* [case site](https://githubcopilotlitigation.com/)
- **[DeVault 2022]** DeVault. *GitHub Copilot and Open Source Laundering.* [post](https://drewdevault.com/blog/Copilot-GPL-washing/)
- **[EU-AIA]** Regulation (EU) 2024/1689 (AI Act). **[EU-CRA]** Regulation (EU) 2024/2847 (Cyber Resilience Act).
- **[Freshfields-PLD]** *Product Risks Today* (revised Product Liability Directive analysis). [post](https://www.freshfields.com/en/our-thinking/blogs/risk-and-compliance/product-risks-today-how-the-new-product-liability-directive-turns-ai-act-complia-102mpu2)
- **[NIST 2024]** NIST SP 800-218 v1.1 (SSDF) and SP 800-218A. [csrc.nist.gov](https://csrc.nist.gov/pubs/sp/800/218/a/final)
- **[Willison 2025]** Willison's vibe-coding demarcation, March 2025, as cited by [Vibe-GLR 2025].
