# HW 4: *3D Stylization*

## Project Overview:
I used a 2D concept art piece of the pokemon mew as inspiration to create a 3D Stylized scene in Unity. 

| <img width="500px" src=https://github.com/user-attachments/assets/a7492aa9-2998-4d00-bb92-512cc893581e/>  | <img width="500px" src=https://github.com/user-attachments/assets/ea0838f1-14de-49ec-a33a-b160678dd558/> |
|:--:|:--:|
| *2D Concept Illustration* | *3D Stylized Scene in Unity* |
### Picking a Piece of Concept Art
I found this illustration of a mew that I really liked from [here](https://www.pinterest.com/pin/283797214017095926). 
### Interesting Shaders
![Screenshot 2025-01-02 at 2 26 46 PM](https://github.com/user-attachments/assets/2023ac51-d427-4fac-9261-47978488a87c)

I implemented multiple light support, and added a rim lighting effect similar to the reflected highlight on the mew's body in the illustration. I also created a custom shadow texture in procreate using a cloud like brush to mimic the painted effect of the illustration, I ended up applying this to the shadow of mew on the floor in the final scene.

![Screen Recording 2025-01-02 at 2 53 50 PM](https://github.com/user-attachments/assets/33a2bfb5-36bb-465b-839b-908c5adf138f)

For my special surface shader, I modified my object shader to animate the vertex positions of the object to bob up and down, kind of like how mew floats. 
### Outlines
![Screenshot 2025-01-02 at 2 41 14 PM](https://github.com/user-attachments/assets/b422893f-7be1-42ee-b6bd-992540272596)

Then I made Post Process Outlines based on Depth and Normal buffers, I adjusted color and strength parameters later on to make the effect more subtle and similar to the inspiration image.
### Full Screen Post Process Effect
![Screenshot 2025-01-02 at 2 50 08 PM](https://github.com/user-attachments/assets/416d11a2-3c9a-46ed-9db4-f5f86118885e)

For my full screen post process effect, I added a vingette that masks the edges of my scene with a moving cloud pattern.
### Creating a Scene

I got my 3d model from [sketchfab](https://sketchfab.com/3d-models/mewpokemon-f888139b8dc84f2193a8a14026c43abc), and the cloud texture from [here](https://www.sidefx.com/docs/houdini/images/nodes/vop/cloudnoise_worley.png). 
### Interactivity
![Screenshot 2025-01-02 at 2 50 57 PM](https://github.com/user-attachments/assets/40ddbf0a-004f-4f0c-9710-891de1615b58)

I created an empty game object to attach my C# script to, which swaps the material attached to the full screen renderer feature. Pressing space toggles between the default scene and a dark mode.
