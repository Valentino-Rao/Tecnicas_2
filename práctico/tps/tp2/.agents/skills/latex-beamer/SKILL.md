---
name: latex-beamer
description: >-
  Create professional LaTeX Beamer presentation slides, academic talk decks, and posters.
  Trigger for presentations, beamer slides, conference talks, seminar talks, and slide decks in LaTeX.
---

# LaTeX Beamer Presentation Skill

This skill specializes in generating academic and technical presentation decks using LaTeX Beamer.

## Key Guidelines

1. **Class & Aspect Ratio**:
   - `\documentclass[aspectratio=169,10pt]{beamer}` (Default 16:9 widescreen layout).
2. **Themes**:
   - Use clean built-in themes: `\usetheme{Madrid}`, `\usetheme{Metropolis}`, `\usetheme{Boadilla}`, or `\usetheme{CambridgeUS}`.
3. **Slide Structure**:
   - Every slide is a `\begin{frame}{Frame Title}{Frame Subtitle}... \end{frame}`.
   - Use `\begin{columns}[T]` and `\begin{column}{0.48\textwidth}` for side-by-side text, code, or images.
4. **Verbatim / Code**:
   - Any slide with `algorithm2e`, `lstlisting`, or verbatim code MUST use `\begin{frame}[fragile]{Title}`.
5. **Citations & Footnotes**:
   - Use `\footnotemark{}` and `\footnotetext{Full citation}` pattern per slide for immediate reading without jumping to bibliography slides.
