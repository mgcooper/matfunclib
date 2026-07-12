# libraster

Tools for building, referencing, gridding, masking, and displaying raster
(gridded) data in MATLAB — for both **geographic** (lat/lon) and **projected
(planar)** coordinate systems.

libraster grew in two layers:

1. **`raster*/` functions** — thin, opinionated wrappers around the MATLAB
   **Mapping Toolbox** (`rasterref`, `rasterize`, `rasterclip`, `rastercrop`,
   `rastercontour`, `rasterinterp`, `rastersurf`). These build/consume Mapping
   Toolbox spatial-referencing objects (`R`) and figures.
2. **`util/` grid functions (the `mapGrid*`/`grid*` family)** — home-rolled grid
   handling that does **not** depend on the Mapping Toolbox for its core logic
   (`mapGridInfo`, `mapGridCellSize`, `mapGridFormat`, `prepareMapGrid`,
   `gridvec`/`fullgrid`, `gridNodesToEdges`, `gridmember`, `scatteredInterpolation`,
   …). These exist because the Mapping Toolbox model is awkward for centroid grids
   (see Conventions below).

> The single most important thing to understand in this library is the
> **cell-center vs cell-edge vs posting** convention and how it interacts with
> MATLAB's plotting and referencing functions. Read the next section first.
> A runnable walkthrough is in `examples/demo_raster_conventions.m`; the
> historical "why" is in `docs/raster-conventions-journey.md`.

---

## Conventions: centers, edges, postings, and "images"

A gridded dataset gives a value at each node of a lattice of `(X,Y)` coordinates.
The perennial question is **what those coordinates mean** and **what each value
represents**. There is no single MATLAB-wide answer — different functions assume
different things — which is the root of nearly all raster confusion.

### Three data models

| Model | A value is… | Coordinates are… | MATLAB functions |
|---|---|---|---|
| **Cells** (raster / image) | an **area** (a pixel/cell) | the **CENTER** of each cell | `image`, `imagesc`, `geoshow(...,'texturemap')`, `maprefcells`/`georefcells` |
| **Postings** (point samples) | defined **at a point** | the **point** itself | `surf`, `mesh`, `interp2`, `griddedInterpolant`, `scatteredInterpolant`, `maprefpostings`/`georefpostings` |
| **Vertices/edges** (the oddball) | a cell **face** | cell **EDGES/corners** | `pcolor` (also silently drops the last row & column of `C`) |

Consequences worth memorizing:

- **`imagesc(x,y,Z)` treats `x,y` as pixel CENTERS** and the image extends half a
  cell beyond the coordinate range. This is the natural "raster image" model.
- **`pcolor(X,Y,Z)` treats `X,Y` as cell EDGES (vertices)** and drops a row/column.
  Feeding it centroids shifts everything half a cell — a classic trap.
- **`surf`/`mesh`/interpolation treat `X,Y` as the sample points** (postings) — no
  cell area; values live exactly at `(X,Y)`.

### Mapping Toolbox: cells vs postings

For a referencing object `R` with limits `[lo, hi]` and `N` samples along an axis:

- **`*refcells`**: `[lo, hi]` are the **outer cell EDGES**. Cell centers are inset
  half a cell. `CellExtent = (hi-lo)/N`.
- **`*refpostings`**: `[lo, hi]` are the **outer POSTING positions** (the first and
  last samples). `SampleSpacing = (hi-lo)/(N-1)`.

So if your netcdf/GCM `lat`/`lon` are cell **centroids** and you naively call
`georefcells([min max], …)`, MATLAB treats them as edges and computes a cell size
that is too small by `N/(N-1)`, with centers offset half a cell.

### How libraster resolves it (the canonical rule)

**libraster canonicalizes on cell CENTERS** — your coordinates *are* the data
locations — and then **adapts per consumer**:

- **Build a `cells` `R` for image display / Mapping Toolbox** →
  **`rasterref`** treats `X,Y` as centers and **pads the limits outward by half a
  cell** before calling `*refcells`. Result: correct cell size, cell centers land
  exactly on the data, and the round trip `centers → R → centers` is exact. This is
  the recommended path and matches `imagesc`/`geoshow('texturemap')`.
- **Need cell EDGES (e.g. for `pcolor`)** → **`gridNodesToEdges`** converts centers
  to the `N+1` edge coordinates.
- **Need the points (for `surf`/`mesh`/interpolation)** → use the centers directly
  (`gridvec`/`fullgrid` give the grid vectors/full grids), or a `postings` `R`.
- **Display** → **`plotraster`** wraps the image/centers interpretation so figures
  are consistent regardless of the trap functions above.

`rasterref(X,Y,cellInterpretation)` — `cellInterpretation` may be given
positionally (`rasterref(X,Y,'postings')`) or as the `'cellInterpretation'`
name-value pair; it is case-insensitive and the singular form (`'posting'`) is
accepted:
- `'cells'` (default): `X,Y` are cell **centers**; limits padded ±½ cell. Use this
  for centroid/climate grids.
- `'postings'`: `X,Y` are the **sample positions** themselves; limits are the raw
  `[min,max]` (no padding). Use this only for genuinely posted (point) data.

---

## Function catalog

### Referencing (build/convert `R`)
`rasterref` (centers → `R`), `R2grid`/`R2grat` (`R` → coordinate grids),
`grid2R`, `patchRbox`/`plotRbox` (`R` bounding box), `isRasterReference`,
`validateRasterReference`, `mapraster`.

### Grid model / format (the `mapGrid*` family, Mapping-Toolbox-free)
`mapGridInfo` (type + cell size + geo/planar), `mapGridCellSize` (uniform/regular/
irregular + cell size; relative-tolerance uniformity via `customIsUniform`, so
float32 storage jitter is accepted but genuine irregularity is rejected),
`mapGridFormat` (fullgrids/gridvectors/
coordinates/point/irregular), `prepareMapGrid`/`prepareGeoGrid`/`prepareGeoCoords`,
`orientMapGrid` (N-S/W-E orientation), `isGeoGrid`/`islatlon` (geographic detection),
`isfullgrid`/`isxyregular`.

### Grid coordinate conversion
`gridvec`/`xgridvec`/`ygridvec` (→ grid vectors, centers), `fullgrid`/`xfullgrid`/
`yfullgrid` (→ full 2-D center grids), `gridNodesToEdges`/`gridCellCorners` (centers
→ edges), `gridmember`/`nearestGridPoint` (membership/nearest), `gridCoords`,
`fastgrid`, `ncorient`.

### Interpolation / gridding
`rasterize` (scattered → raster, `griddata`; subfns `gridmapdata`/`gridgeodata`),
`gridxyz` (gridded-but-gappy, multi-column gap-fill via `scatteredInterpolation`),
`scatteredInterpolation` (wraps `scatteredInterpolant`; accepts gridded or
irregular input via `validateScatteredData`), `rasterinterp`.

**Which gridder?** The boundary is *"are the input coordinates already on a
grid?"* — decided with `mapGridInfo` (the same classifier `prepareMapGrid` uses):

| Input | Tool | What it does |
|---|---|---|
| Already on a grid (uniform/regular), **may have gaps**, single layer | `rasterize` *(regular branch)* | builds the implied full grid via `prepareMapGrid`, **places** values onto it by the I/LOC map (no interpolation of existing data); optional `inpaintn` gap-fill under `'extrap'` (valid only because the grid is uniform — `inpaintn` ignores coordinates) |
| Already on a grid, gappy, **one or many** layers, coordinate-aware gap-fill | `gridxyz` | same `prepareMapGrid` placement, then `scatteredInterpolation` (uses x,y) to fill only the missing cells |
| Genuinely **scattered** (not on any grid) → new raster at a chosen resolution | `rasterize` *(scattered branch)* | invents a regular cell-center grid (false-precision-aware, directionally-rounded extent) and `griddata` interpolates onto it; trims cells outside the data's concave `boundary` |

Rule of thumb: gridded-but-gappy → `gridxyz` (or `rasterize` for a single layer);
truly scattered → `rasterize` with a `rasterSize`/`cellextent`. `rasterize`
gap-fills with `inpaintn` (coordinate-free, uniform grids only); `gridxyz`
gap-fills with coordinate-aware `scatteredInterpolation`.

### Masking / display / extraction
`plotraster`, `plotMapGrid`, `maskraster` (mask==true ⇒ remove), `coverlay`,
`rastersurf`, `rastercontour`, `rasterclip`/`rastercrop`, `floodFillExterior`,
`mapGridOutline`, `mapbox`, `imageSizeInXY`.

### Geometry / area / projection
`geoarea`/`earthSurfaceArea`/`llpoly2steradians` (areas), `gridCellCorners`,
`parseMapProjection`/`copygeoprjtemplate`, `fix_geometries`, `arcgridwrite2`.

### Validation helpers
`validateGridData`, `validateGridCoordinates`, `validateGridFormat`,
`validateInterpMethod`, `validateScatteredData`, `checkGrid`.

### Test data
`defaultGridData` derives a default grid on the fly from the bundled
`data/test/rasterref/example_cells.tif` (no saved `gridded.mat`).

---

### Note on earth surface area calculations

`libraster` contains three thin wrappers over `libspatial`'s sphericalpolyarea:

| Wrapper | What it adds | Needed? |
|---------|--------------|---------|
| `geoarea` | CW-positive convention, per-part handling, WGS84 default | Keep as the primary named geographic-area API; decide if `exactremap` should call it. |
| `earthSurfaceArea` | Units (deg/rad) + fraction-of-sphere normalization | Largely redundant with `geoarea`; Consider deprecating, only an example script calls it. |
| `llpoly2steradians` | `abs` on the unit sphere: default ellipsoid = [1 0] | Optional convenience; E3SM runoff scripts use it. |

---

## See also
- `examples/demo_raster_conventions.m` — runnable demonstration of the
  centers/edges/postings/image differences.
- `examples/` — `demo_coverlay`, `demo_floodfill`, `demo_gridmember`.
- `test/` — class-based unit tests (`matlab.unittest`).
