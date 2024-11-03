# HW 4: *3D Stylization*

## Project Overview:
In this assignment, you will use a 2D concept art piece as inspiration to create a 3D Stylized scene in Unity. This will give you the opportunity to explore stylized graphics techniques alongside non-photo-realistic (NPR) real-time rendering workflows in Unity.

| <img width="500px" src=https://github.com/CIS-566-Fall-2023/hw04-stylization/assets/72320867/755780f1-8b8c-47e1-b14f-3a619f92fd3a/>  | <img width="500px" src=https://github.com/CIS-566-Fall-2023/hw04-stylization/assets/72320867/70550c09-ba75-4d10-9b30-60874179ad10/> |
|:--:|:--:|
| *2D Concept Illustration* | *3D Stylized Scene in Unity* |
### HW Task List:
1. Picking a Piece of Concept Art
2. Interesting Shaders
3. Outlines
4. Full Screen Post Process Effect
5. Creating a Scene
6. Interactivity
7. Extra Credit

---
# Tasks

## 0. Base Project Overview

After forking the repo, take a moment to watch this brief HW/Base Project Overview which goes over things that you're expected to bring over from the lab, and etc.
- [See the Project Overview here](https://youtu.be/JmVTmpgSz5U)

## 1. Picking a Piece of Concept Art
The concept art I am inspiring my scene off of is a piece of visual development done by Chris Sanders when developing the Disney film Lilo and Stitch. I really enjoy the water color aspects of it!

![lilostitchconceptart](https://github.com/user-attachments/assets/f146f97e-b5a8-4012-bd1f-59d7832346c3)
---
## 2. Interesting Shaders

Creating two custom shaders to emulate the watercolor-like texture and feel of the concept art, my first shader utlizied my three tone shader and added noise to it, as well as watercolor textures, then adding Fresnel noise to add a rim around it to look like paint fading at the edges. I then also created a second shader for the background that utilized Voronoi noise and a custom MapCircle function to create a paper-like surface. I wanted it to be similar to the first shader, in that it looks watercolor-like, but also have its own look and act more of a background.

   ![shaders](https://github.com/user-attachments/assets/77e38ba6-8dbe-4c00-b830-452446e17ac9)

---
## 3. Outlines
As show in the image above in #2, I used normal and depth buffers, as well as Render Features to create a black outline that gives an inked look. I think it works especially well for my project given the concept art!

---
## 4. Full Screen Post Process Effect 
I also added a second overlay full screen vignette effect. I was particularly inspired by older films and television shows where the color and saturation of what is happening on screen fades as it goes to the edges. I also wanted the perspective of the viewer to be looking down directly at a piece of paper as they were working, so it made sense.

---
## 5. Create a Scene
Using free 3D Models and my shaders, I compiled a scene reminiscent of Lilo and Stitch!



https://github.com/user-attachments/assets/7bc279a1-6926-4aad-8b74-ec4d5702c069




---
## 6. Interactivity
When in gameplay. click to speed the water up!



