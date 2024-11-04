# HW 4: *3D Stylization*

## 1. Picking a Piece of Concept Art
I liked the image of link drawn in colour pencil, so I picked this one:

![](https://github.com/CIS-566-Fall-2023/hw04-stylization/assets/72320867/9c345ee6-19df-4191-9e47-6722b6597a5a)  
*https://twitter.com/trudicastle/status/1122648793009098752*

---
## 2. Interesting Shaders

For the first part of the HW I finished our toon shader by implementing multiple light and colour support, along with special shadows like this. It was unnecessary for my pencil shader, so I just decided to do it for the toon shader:
<img width="677" alt="Screenshot 2024-11-03 at 10 17 00 PM" src="https://github.com/user-attachments/assets/2f7de537-fe32-4a04-ade8-8012a6c262ac">

Of course, I also made a basic pencil shader, complete with interesting shadows (the edges were postprocessing). I used a pencil texture input as a filter for where to draw the mesh's albedo texture. Since it seems like someone had already made that shader, I made my pencil texture and noise look slightly different from the picture (for the sake of uniqueness). 
<img width="467" alt="Screenshot 2024-11-03 at 10 19 37 PM" src="https://github.com/user-attachments/assets/bd307a4f-5d74-4d75-9188-d758091755cd">
However, there were some long blank lines that I couldn't seem to remove no matter how I mapped the static pencil texture. That is why I made an improvement in the next part of the shader.

3. **Special Surface Shader**
For this part, I made the pencil texure animated. Firstly, this was because it made the continuities look less obvious, and also t make it seem like the texture was being drawn in real time every frame. The texture animates with the movement of the camera to imitate the way that the gif of this image moves as well.

---
## 3. Outlines

I then created post process outlines using the depth and normal technique, and animated it using a gradient noise and time to make the image feel like its being drawn in real time by someone. 

Additionally, I created an alternative outline using inverse hull rendering, where for each mesh I made a copy, created a new shader that only rendered backfaces for each copy, and increased their sizes so that each mesh had a larger black version surrounding it.

---
## 4. Full Screen Post Process Effect

I created a full screen post process effect by multiplying the scene's output with a paper texture to make it seem like everything was being drawn on paper.

---
## 5. Create a Scene

I couldn't find a good link mesh that worked in unity, so I found a wolf link mesh instead, and attached the shader to that. I also found a cool wither mesh and added that to the scene because why not?

---
## 6. Interactivity

Here is interactivity:
Spacebar: Switches between both meshes, along with normal draw mode and "static mode" (where the pencil strokes look like static interference instead)

E: Switches edge rendering mode

W: Switches between animated and static materials
 
---
## 7. Extra Credit
Simple skybox: I added a very fast day/night cycle to show the movement and fading of shadows, and also made the skybox have a cool glow in the ground when the sun was down. Of course, I don't let the model darken because you wouldn't be able to see the shader if that happened.

## Submission
Video: https://github.com/virajdoshi02/hw04-stylization/blob/main/Assets/Recording.mov
