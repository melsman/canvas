import "/futlib/math"
import "../lib/github.com/athas/matte/colour"
import "../lib/github.com/diku-dk/cpprandom/random"
import "../lib/github.com/melsman/canvas/canvas"

type colour = argb.colour

type state = { lines: [](line.t,colour)
             , triangles: [](triangle.t,colour)
             , h: i32
             , w: i32 }

module engine = minstd_rand
module distribution = uniform_int_distribution i32 engine

let mk_lines (h:i32) (w:i32) (n:i32) (rng:engine.rng) : ([n](line.t,colour), engine.rng) =
  let rngs = engine.split_rng n rng
  let pairs = map (\ rng ->
                   let (rng,a) = distribution.rand (0, w - w / 10) rng
                   let (rng,b) = distribution.rand (0, h - h / 10) rng
                   let (rng,c) = distribution.rand (0, w / 10) rng
                   let (rng,d) = distribution.rand (0, h / 10) rng
                   let c = a + c
                   let d = b + d
                   in ((({x=a,y=b},{x=c,y=d}),argb.blue),rng)) rngs
  let (res, rngs) = unzip pairs
  in (res, engine.join_rng rngs)

type x = (i32,i32)
let mkt (p1:x,p2:x,p3:x) = (({x=p1.1,y=p1.2},{x=p2.1,y=p2.2},{x=p3.1,y=p3.2}),argb.red)
entry load_image (h:i32) (w:i32) : state =
  let seed = 43.0
  let rng = engine.rng_from_seed [i32.u32 (f32.to_bits seed)]
  let (lines,_rng) = mk_lines h w 5000 rng
  let triangles = --[mkt((50,10),(10,80),(100,80))]
                  [mkt((50,110),(10,180),(100,180))]
               ++ [mkt((100,20),(30,40),(200,70))]
               ++ [mkt((200,20),(280,40),(300,80))]
               ++ [mkt((100,100),(300,500),(800,100))]
  in { lines
     --    [((58,20),(2,3)),((27,3),(2,28)),((5,20),(20,20)),
     --     ((4,10),(6,25)),((26,25),(26,2)),((58,20),(52,3))]
     , triangles
     , h
     , w }

entry render (state: state): [][]i32 = unsafe
  let grid = canvas.mk state.h state.w
  let grp = (canvas.triangles state.triangles) canvas.&&& (canvas.lines state.lines)
  in canvas.raw(canvas.draw grp grid)

entry advance (state: state): state =
  {lines=map (\ (({x=a,y=b},{x=c,y=d}),col) ->
              let a = a +1
              let c = c +1
              in (({x=a,y=b},{x=c,y=d}),col)) state.lines
  , triangles=map (\(t,c) -> (triangle.transl {x=1,y=0} t,c)) state.triangles
  , h=state.h
  , w=state.w }
