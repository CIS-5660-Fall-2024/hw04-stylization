# Take Me Out! - Unity Stylization Exploration

## Project Overview:
This is an exploration into stylized shading using Unity's ShaderGraph. For my project, I chose the "Dadaist" animation style scattered with elements of collage and pop from Scottish band Franz Ferdinand's hit music video and song "Take Me Out". Below is how it turned out in the end (obvious sound credit to Franz Ferdinand)! [I highly recommend you watch a tiny bit of the music video here](https://www.youtube.com/watch?v=Ijk4j-r7qPA)

https://github.com/user-attachments/assets/24a19016-c75c-460a-9307-9ce4da7216b9

| <img width="500px" src=https://github.com/user-attachments/assets/bc9ed95a-8730-4556-bf10-b209833457ab/>  | <img width="500px" src=https://github.com/user-attachments/assets/f563a274-1fbd-4d98-bfa1-23fc71359f18/> |
|:--:|:--:|
| *2D Concept Illustration* | *3D Stylized Scene in Unity* |

To interact with the scene, press "Space" to swap materials, "P" to distort geometry, and "F" to do both, taking you out!

### Overall details:
- Voronoi dithering
- Noise-affected thresholds for shading
- Screenspace textures blended with toon shading
- Custom rendered background using noise-masks and polar nodes
- Distorted outlines
- Stop-motion animated textures using UV-offsets and time-stepped functions
- Custom vignette filter node
- Noise-based grain/artifacts effect
- Camera jitter script
- Interactive material swapping

---
# Basic surface shading
We begin with a simple toon-shader to break down lighting into three colors: **base color, mid-tone, and shadow color.** This is done by taking dot(light vector, normal), or Lambert's cosine law, to apply some basic diffuse shading.
Using our dot product, we can check if it exceeds threshold levels to determine if it's an albedo, mid-tone, or shadow color.

To add rim highlightings, I used a combination of Blinn-Phong specular and a Fresnel node, adding the sum to my highlights threshold.
<img width="689" alt="image" src="https://github.com/user-attachments/assets/88345560-69d9-4c3a-965a-9dcfa00825ec" />


For my shadows, I used my screenspace coordinates to sample a rotated voronoi grid to make a dotted shadow. 
I then multiplied the result by a pencil on paper image to add some grain and texture.
<img width="677" alt="image" src="https://github.com/user-attachments/assets/5b2e26c5-c35b-4dfa-9ea5-9342dbf4faf0" />

The overall look, in a static image, looks like this now:

<img width="415" alt="image" src="https://github.com/user-attachments/assets/6b93678a-1ed0-4215-816b-b5ce5f2938ce" />

---
# The Element of Time (Animating it)
We can make this much more exciting by animating our shading, using time nodes to manipulate our thresholds and textures.
To add some simple choppy animation to our shader, we can mathematically split up time into discrete segments by the eq:
t' = floor(n * t) / n, with t = time, and n = frame rate. 

<img width="516" alt="image" src="https://github.com/user-attachments/assets/20e2528b-af6d-412d-b8ee-3e428ccc6862" />

We can then use t' as an offset to our UV coordinates for texture or noise reads, making our scene look like an inconsistent and chaotic animation.
Manually piecing together **FBM noise**, for example, with the time element gets us some pretty cool results that we can then add to our thresholds.

![ezgif-2-cc906273f1](https://github.com/user-attachments/assets/0bf3171d-bfd5-406e-a6ba-31855396231d)

We can use this same approach to multiply our output color by another paper texture to get the screen-space paper effect.
<img width="544" alt="image" src="https://github.com/user-attachments/assets/bfad25bd-aec8-4b1d-8123-7a6ec4339d25" />

Check out the new look, I'd say we're closer to the *Take Me Out* style compared to the start.
![ezgif-2-2458130414](https://github.com/user-attachments/assets/b601f48f-e634-44a8-aa88-010e717b7284)

---
# Post-Processing: Getting edgy, noisey, and vignette-y
I won't get into setting up the post-processing pipeline that much (we render to a buffer, then render another image using the buffer to the screen), but I will get into what post-processing I did.
There are a few main effects I used:
- Edge outlines
- Old film noise
- Vignette

## Edge Outlines
I first made a custom node to detect edges, using the same approach in this article: https://ameye.dev/notes/edge-detection-outlines/
The idea is that, for a given pixel, if we can check for high depth discontinuities for surrounding pixels, then it's likely that there's an edge there.
We can use the same idea for normals and colors that may also be likely candidates for edges, requiring us to have a depth and normal buffer as well.
Using our cool time-offset trick from before, we can, again, re-use that to offset our outline-detection UV sample for a fun, wobbly, animated look.

<img width="437" alt="image" src="https://github.com/user-attachments/assets/3e714b0e-ea82-4c22-8da3-bd2d9032ca49" />

## Film Noise
Nothing that new, but we again use that time-offset. I split my film noise into two segments, one for mottled white splotches (bottom) and one for general film grain (top).
It's important to first note that the outline node returns the MainTexture with outlines applied, so if I want noise, then I'd either have to multiply or lerp between that and a noise value.
That being said, that's why the lerp node is there.

![ezgif-7-b1cc68adfe](https://github.com/user-attachments/assets/0a9570ad-dab2-422a-a573-6ad97aeb9fc6)

On the top, our film grain is a simple noise read with a saturation to correct [-1,1] to [0, 1], and a power to amplify its contrast.
Below, we want some streaks of white that occasionally pop-up in old films, so I apply a step function after my power, proceeded by a one-minus so I can add it to my above noise.
(Note: the noise reads are not the same, the noise below has a lower frame-rate than the one above!)

## Vignette
We now reach the final step: applying the vignette. I wrote a custom-node for this, translated from https://www.shadertoy.com/view/Wdj3zV
<img width="515" alt="image" src="https://github.com/user-attachments/assets/e9ca6001-02d7-4bf9-ab11-aa7daa77bda1" />

## Post-Processing Results:
![ezgif-7-114156400c](https://github.com/user-attachments/assets/1a641c5a-0c1a-4cf0-a968-e5b710d19ab7)

I slightly had to crop this for Clipchamp, but it's looking really cool now!

---
# The Background
We still have a background to finish, as ever present in the *Take Me Out* music video. Most of what makes that video fun is the background.
To do this, we need an additional render pass for the background, which can be done before we render any objects (for my project's deferred rendering setup, that's before G-Buffer).
Like the post-processing, there are a few elements I stich together for the back:
- Shaking background
- Scrolling Dots
- Audio Ripple

## Shaking Background
Like many things in the video, the background texture shakes a lot! To get this effect, I made a UV offset = vec2(cos(t), sin(t + noise(xy)).
This offset is a parameterized circle over time, but with some slight noise to add jitter, making stuff shake.

<img width="497" alt="image" src="https://github.com/user-attachments/assets/4588ea77-dd6a-408d-ae26-5cc8dcc3f592" />

The multiply node at the end is vec2(0.005, 0.005). 

Again, using screenspace coordinates and our shaking offset, we can compose our background picture. I decided, for visual variety,
to combine two pictures separately, using noise as a mask so we can lerp between them, stitching them together.

<img width="556" alt="image" src="https://github.com/user-attachments/assets/bd1aeb61-3ff8-487e-9996-43cb9cc60c53" />

## Scrolling Dots
*Take Me Out* loves to also have tons of moving geometry in the background. I chose to recreate the scrolling dots found around the one-to-two second marks.
I first make a scrolling UV sample, where speed = 0.6 * time, and offset = vec2(speed, speed), feeding that into Tiling And Offset.
To get our dots, we do a one-minus to get a mask, and then apply a step. We can then multiply this result with our output, such that we keep everything (mul by 1) but apply dots (mul by 0).

![ezgif-7-2cabba41ed](https://github.com/user-attachments/assets/65f2569b-a335-405d-a7bd-d52c27eb0ab0)

## Audio Ripple
At [1:24](https://youtu.be/Ijk4j-r7qPA?si=WeUb4sZRilLP7yAM&t=84), there's a really cool but brief ripple effect. Having worked with polar coordinate nodes before,
I decided to recreate this as well.

![ezgif-1-67a76034d4](https://github.com/user-attachments/assets/bb34746e-5f23-4396-95fe-f046699ca4af)

On the top, we use a polar coordinate node to make the ripple. The node's R channel represents distance "r" to center for a given UV.
Using r, we can get a wobble by letting p = sin(frequency * (r + speed * time)), resulting in the hypnotizing node in the GIF. I then use a step node to thin the ripples.
To fade out the ripples, I add the result by another polar coordinate distance float, but this time smoothstepping it so that it naturally fades from black to white the greater r is.
This ends up working pretty well, since any values > 1 (far away from center) will naturally get clamped to 1 by our saturation, resulting in the final output.

## The Results
Multiplying the results of each step together, we get this:

![Untitledvideo-MadewithClipchamp12-ezgif com-optimize](https://github.com/user-attachments/assets/dbd59747-e682-495f-a17f-480648ff77d4)

---
# Scene Construction/User Interactivity
If you've made it this far, that's firstly great, but secondly I won't introduce anymore cool shader elements at this point.
For my overall look, I found a new models of guitars and drums on Sketchfab, attempting to rebuild the band without the members.

Around [1:17](https://youtu.be/Ijk4j-r7qPA?si=JikSF8WsCw-OgTt6&t=77) though, there are scattered bits of morphing geometry that I found pretty cool, so I incorporated that into my scene as well.
This is the "distort geometry" bit of my project, but all it does is scale the geometry by a random Vector3, then lerping between the scales. I let the user press "p" to activate it.

Besides that, there's also a turning camera and a simple material-swapping animation too.

Overall, this is the final result, and I'm very happy with it:
<img width="500px" src=https://github.com/user-attachments/assets/f563a274-1fbd-4d98-bfa1-23fc71359f18/>

Thanks for checking out my README, and feel free to find more projects at [geant.pro](https://www.geant.pro/).
## Resources:
- [Drum kit model](https://sketchfab.com/3d-models/american-idiot-drum-kit-fbc02f9a2ca14992a692297f8f06f095)
- [Guitar + amp model](https://sketchfab.com/3d-models/ljas-guitars-amp-299481c99a40490985678f9a227f5bfa)
- Edge Detection Approach: https://ameye.dev/notes/edge-detection-outlines/
- Vignette: https://www.shadertoy.com/view/Wdj3zV
