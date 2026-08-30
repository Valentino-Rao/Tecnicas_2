---
name: latex
description: >-
  Produce high-quality, compilable LaTeX documents, Beamer presentations, and snippets.
  Trigger whenever creating, formatting, typesetting, or editing .tex files, academic papers,
  reports, slides, resume/CV, exam/study guides, formulas, TikZ figures, or algorithms in LaTeX.
---

# LaTeX Document Generation and Formatting Skill

This skill governs the production of clean, professional, immediately compilable LaTeX for documents, academic papers, reports, Beamer presentation slides, study guides, and snippets.

---

## 1. Request Classification & Modes

Choose one of the **three** output modes based on user intent:

### Mode A: BEAMER MODE (Presentations & Slides)
Trigger when the user mentions: `slides`, `presentation`, `beamer`, `slide deck`, `talk`, `seminar`, or `conference talk`.
- Use `\documentclass[aspectratio=169,10pt]{beamer}`
- Use standard built-in themes (`Madrid`, `Metropolis`, `Berlin`, `CambridgeUS`, `Boadilla`).
- Format each slide using `\begin{frame}{Frame Title}... \end{frame}`.
- For code/pseudocode inside frames, add the `[fragile]` option: `\begin{frame}[fragile]{Title}`.
- Place footnote citations directly on the slide using `\footnotemark{}` and `\footnotetext{}`.

### Mode B: DOCUMENT MODE (Full Standalone Articles, Reports, Study Guides)
Trigger when generating full standalone `.tex` files for reports, guides, papers, or homework.
- Use `\documentclass[11pt,a4paper]{article}` or `report` / `book`.
- Include full preamble, packages, definitions, `\begin{document}`, and `\end{document}`.
- Always ensure syntax compilation without errors.

### Mode C: SNIPPET MODE (Fragments, Equations, Tables, TikZ)
Trigger when the user requests only a formula, equation, table, TikZ diagram, or code block fragment.
- Provide raw LaTeX body content without `\documentclass` or `\begin{document}` unless explicitly asked.

---

## 2. Standard Preamble & Package Best Practices

### Recommended Packages:
```latex
\documentclass[11pt,a4paper]{article}

% Core Math & Symbols
\usepackage{amsmath, amssymb, amsthm, mathtools}
\usepackage{bm}            % Bold math symbols
\usepackage{dsfont}        % Math indicator functions

% Page Layout & Margins
\usepackage[margin=2.5cm]{geometry}
\usepackage{microtype}     % Improved typography/kerning
\usepackage{parskip}       % Space between paragraphs instead of indent

% Colors & Custom Boxes
\usepackage[table,xcdraw]{xcolor}
\usepackage{tcolorbox}
\tcbuselibrary{skins, breakable, theorems}

% Tables & Formatting
\usepackage{booktabs}
\usepackage{tabularx}
\usepackage{array}

% Code Listings
\usepackage{listings}

% Graphics & TikZ
\usepackage{graphicx}
\usepackage{tikz}
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}

% Links & References
\usepackage[colorlinks=true,linkcolor=blue,citecolor=blue,urlcolor=blue]{hyperref}
\usepackage[capitalise,noabbrev]{cleveref}
```

---

## 3. Critical Compilation & Formatting Rules

To avoid common `pdflatex` compilation errors:

1. **Escaping Special Characters**:
   - Always escape `#`, `$`, `%`, `&`, `_`, `{`, `}` outside of math mode or code blocks.
   - For tildes use `\textasciitilde`, for carets `\textasciicircum`, for backslashes `\textbackslash`.
   - Never use raw `->` outside `lstlisting`; use `$\rightarrow$` or `\textrightarrow{}`.

2. **Listing & Verbatim Environments (`lstlisting`)**:
   - Inside `\begin{lstlisting} ... \end{lstlisting}`, **DO NOT** use special non-ASCII characters (like Spanish accents `á, é, í, ó, ú, ñ`) unless properly configured with `literate` or ASCII equivalents.
   - Never nest `lstlisting` inside macro parameters or certain tcolorbox titles without `[fragile]`.

3. **Babel Spanish Specifics**:
   - If using `\usepackage[spanish]{babel}`, call `\shorthandoff{"}` right after `\begin{document}` to prevent quotes from breaking layout and string shifts.

4. **Math Mode Safety**:
   - Avoid raw `\text{ \mu s}` in tables or display math. Use `$\mu\text{s}$` or custom macro definitions.
   - Do not use undefined macros. Always define custom commands with `\newcommand` in the preamble.

5. **Box & Layout Overflow**:
   - Keep line lengths reasonable and avoid `Overfull \hbox` warnings.
   - Use `\adjustbox{max width=\textwidth}` for wide TikZ diagrams or `tabularx` for auto-wrapping table columns.

---

## 4. Workflow for Generating LaTeX Documents

1. **Understand Structure & Topic**: Outline the sections clearly with appropriate sectioning (`\section`, `\subsection`, `\subsubsection`).
2. **Draft Preamble**: Include only necessary packages without conflicting packages (e.g., don't mix `subfig` and `subcaption`).
3. **Write Content**: Use clear visual hierarchy, colored `tcolorbox` highlight boxes for key formulas, definitions, or notes.
4. **Compile & Verify**:
   - Always test compilation using `pdflatex -interaction=nonstopmode <filename>.tex`.
   - Run a second pass for cross-references and table of contents.
   - Inspect log for errors/warnings and fix any undefined control sequences or unescaped characters.
