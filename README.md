# HW 4: *3D Stylization*

## Implementation

I chose to attempt to replicate a style like that of this concept art:

<img width="500px" src=https://github.com/jeff-mostyn/hw04-stylization/blob/main/Assets/Models/Pokemon/sourceimages/pokemon%20in%20hoodies.jpg?raw=true/> 

which evoked something like crayon or colored pencil on lightly textured paper.

My intent was to have the light and shadow blend in to the neutral color with noise that would dissolve between the colors, creating the impression of a gradation while still using the limited shading palette of toon stylization. The other aspects of the render would similarly have "weathering" applied to evoke the feeling of textured paper being colored over with a physical media such that small flecks of the paper's color would still show through, and that roughness would also itself slightly affect the coloration of the image.

The features I implemented:

- Stippled Toon Shader: basic toon shader augmented by threshold-modified noise to dissolve between the discretized shading levels. Areas that received no light would have a screen-space hatching applied to them. (I wanted this to be object-space hatching, but did not have the time to UV my meshes cleanly enough for this to work). The material is capable of taking either a solid color or a texture (so long as the texture conforms to the UVs of the object in question).
- Post-Process Outline Shader: outline shading combining depth and normal buffer data to generate outlines using Robert Cross algorithm.
- Post-Process Animated Noise: This was applied independently to the outlines and the entire render, with the outlines having a higher-frequency application, and a lower cutoff for rendering noise overlay. Both applications use a timed cycle to change the sample position for the noise texture, so that the noise shifts periodically to give the image some movement and life, even when things are static.
- Post-Process Edge Dissolve: The edge dissolve was not something that originated from the concept art. Rather, as I was developing the rest of the stylized shader suite, I thought that adding an edge dissolve to make the image look like it was entirely sitting on a piece of paper would enhance the feeling of the shader. This was relatively simple, just further noise application, with a cutoff that linearly interpolated from 0-1 from the edge of the image in. The range of the lerp is configurable in the shader.
- Alternate "Party Mode" Toon Shader: Utilizing a black/white mask, animated color is applied to certain areas of the model. It is activated with the space bar. In the case of the Magnemite, the ends of its magnets and its eye flash in color.

## Credits

- Concept art - I unfortunately could not trace down the artist who originally made the concept art I chose. Despite reverse-image-searching it, many of the oldest sources would not load. The image itself has been reposted around the internet since at least 2017 or so.
- "Stylized tree bark" (https://skfb.ly/onqYK) by Michalina "Miszla" Gąsienica-Laskowy is licensed under CC Attribution-NonCommercial-ShareAlike (http://creativecommons.org/licenses/by-nc-sa/4.0/).

