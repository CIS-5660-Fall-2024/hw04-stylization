# HW 4: *3D Stylization*

## Turnaround

https://github.com/user-attachments/assets/119204ce-3f9f-4c7b-9b4c-02729261585c

## Concept Art

Inspired by Team Fortress 2 concept art (Valve Software)

<table>
  <tr>
    <td style="text-align: center;">
      <img src="https://github.com/user-attachments/assets/9d903f30-67ad-49e1-a2c4-561a948ef626" width="400"/>
    </td>
    <td style="text-align: center;">
     <img src="https://github.com/user-attachments/assets/0e396534-6a07-47fa-a65f-e483cb5bcee1" width="400"/>
    </td>
  </tr>
</table>

## Description

### Specular Highlight

Blinn-phong toon specular highlight. There are options to set its color, strength, brightness.

<img width="330" alt="image" src="https://github.com/user-attachments/assets/d142ddaf-d08a-4d72-b980-40eaa4c72c81">

### Shadow Texture

Checkerboard pattern

<img width="526" alt="image" src="https://github.com/user-attachments/assets/33ed31df-3cab-44ba-a294-708070874e88">

### Rim Light Shader (Special Surface Shader)

Similar to Fresnel effect, there are parameters to adjust parameters of edge/shadow falloff and strength.

https://github.com/user-attachments/assets/9ce48252-98c5-4218-974a-fef1293aa65e

### Outlines

Width is animated using stepped (toolbox function) noise.

## Full Screen Post Process Effect

Overlay to make the image look like it is drawn on paper. Tiling paper texture is blended on top of render. Paper UV is animated/offset using stepped noise.

## Interactivity

Press space to enter "party mode." New surface shader is applied that animates a cosine color curve. The model also scales to create movement. Another full screen post process effect is applied that consists of a vignette made using a voronoi noise pattern, which is colored according to another cosine color curve.

https://github.com/user-attachments/assets/72113652-a194-4ef4-bd97-75124c50637f

## Model Credit

https://sketchfab.com/3d-models/sentry-turret-team-fortress-2-29a9ff6015734e3c80486796326d8ee5
