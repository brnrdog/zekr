open Xote

// The zekr "suite ring" mark: eight passing segments around a check.
// Colours come from CSS tokens so the mark follows the theme.

let svgEl = (tag, attrs) => Node.element(tag, ~attrs=attrs->Array.map(((k, v)) => Node.attr(k, v)), ())

let mark = (~size: int=28) => {
  let s = Int.toString(size)
  Node.element(
    "svg",
    ~attrs=[
      Node.attr("class", "logo-mark"),
      Node.attr("width", s),
      Node.attr("height", s),
      Node.attr("viewBox", "0 0 32 32"),
      Node.attr("aria-hidden", "true"),
    ],
    ~children=[
      svgEl(
        "circle",
        [
          ("cx", "16"),
          ("cy", "16"),
          ("r", "12.5"),
          ("fill", "none"),
          ("stroke", "var(--pass)"),
          ("stroke-width", "3.5"),
          ("pathLength", "80"),
          ("stroke-dasharray", "8 2"),
          ("transform", "rotate(-85.5 16 16)"),
        ],
      ),
      svgEl(
        "path",
        [
          ("d", "M11 16.5l3.5 3.5 6.5-7.5"),
          ("fill", "none"),
          ("stroke", "var(--pass-text)"),
          ("stroke-width", "3"),
          ("stroke-linecap", "round"),
          ("stroke-linejoin", "round"),
        ],
      ),
    ],
    (),
  )
}

// Mark plus the lowercase wordmark.
let lockup = (~size: int=28) =>
  <span class="logo-lockup">
    {mark(~size)}
    <span class="logo-text"> {Node.text("zekr")} </span>
  </span>
