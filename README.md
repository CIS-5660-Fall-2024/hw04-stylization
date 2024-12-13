I got permission from Rachel to submit late (11/7)

# HW 4: *3D Stylization*

## Project Overview:
In this assignment, I used 2D concept art from the animator [Vewn](https://www.youtube.com/channel/UCd0zIZlbgvEifm_hd3FwlBQ) as inspiration to create a 3D Stylized scene in Unity. This gave me the opportunity to explore stylized graphics techniques alongside non-photo-realistic (NPR) real-time rendering workflows in Unity.

https://github.com/user-attachments/assets/c3b7a468-6ed5-412a-9ec8-bf2d359b584b

## 1. Picking a Piece of Concept Art

I chose to try to emulate artwork from the 2D animator Vewn. I really like how distinct her style is and wanted to try to emulate it!

![maxresdefault (2)](https://github.com/user-attachments/assets/72e5f6d9-dd50-412c-b2ba-439675c25bc8)

---
## 2. Interesting Shaders

   I implemented multiple light support with this [tutorial](https://youtu.be/1CJ-ZDSFsMM) as well as rim lighting with this [tutorial](https://www.youtube.com/watch?v=jcMRaFF9RRI):
         
   <img width="800" alt="Screenshot 2024-12-01 at 4 04 55 PM" src="https://github.com/user-attachments/assets/f2463e60-0edc-4206-a9a2-1bde0b8e4490" />

I then created my own custom shadow texture in Procreate and used [this online tool](https://www.imgonline.com.ua/eng/make-seamless-texture.php) to make my texture seamless/tesselatable! I then modified my shadows using this custom texture. To get a consistent looking shadow texture scale across multiple objects, I used an exposed float parameter, "Shadow Scale," that adjusts the tiling of the shadow texture.

<img width="800" alt="Screenshot 2024-12-01 at 4 03 49 PM" src="https://github.com/user-attachments/assets/dc5ddd3d-565a-416f-9341-68a00c17f7c2" />

In the concept art I was referencing, the artist doesn't really use stylized shadows except for really dark shadows:

<img width="800" alt="Screenshot 2024-12-01 at 4 03 49 PM" src="https://github.com/user-attachments/assets/cfac08b1-1127-47c2-993d-5ec8f4eac556" />

so I only used this custom shadow in the window of my final scene
<img width="800" alt="Screenshot 2024-12-12 at 7 28 38 PM" src="https://github.com/user-attachments/assets/27e518d5-5625-4e6f-a820-3588a24c087b" />

I then created a special second shader for the TV to make it look like it's on. To do so I created an animated surface shader that flashes through a bunch of different colors that are within the color palette of my concept art. I also used noise to create animated TV static.

https://github.com/user-attachments/assets/9991eabc-a661-4bb4-bfdb-e4ec7d3a9241

I also created a transparent shader with a gradient texture for the alpha channel to mimic volumetric lighting to make it look like the TV is glowing

<img width="800" alt="Screenshot 2024-12-12 at 7 34 59 PM" src="https://github.com/user-attachments/assets/3b3a7df3-9fde-4f00-9e75-40cb043abff1" />

---
## 3. Outlines

I then created animated Post Process Outlines based on Depth and Normal buffers by referencing [this tutorial](https://youtu.be/RMt6DcaMxcE?si=WI7H5zyECoaqBsqF)

 <img width="800" alt="Screenshot 2024-12-12 at 2 13 18 AM" src="https://github.com/user-attachments/assets/afb1994f-2ab2-4fe7-8e4f-d3735903428c" />

---
## 4. Full Screen Post Process Effect

Some frames of Vewn's animations look like they have a construction paper texture overlayed, so I wanted to emulate that look with a full screen post process effect. I found a paper texture online and then animated it:

https://github.com/user-attachments/assets/e62a7b69-cf9c-4716-bbd5-c9b87b87ec13

---
## 5. Create a Scene

I downloaded my 3D models off of Sketchfab:

TV: https://skfb.ly/owJNH

Cockroach: https://skfb.ly/6BPQU

I then changed the colors of my materials to match Vewn's style.

## 6. Interactivity

I created a C# script to add interactivity to my scene. Whenever the the space bar is pressed, the scene alternates between the "normal" mode and "scary mode," which I modeled after this:

<img width="800" alt="Screenshot 2024-12-12 at 7 52 34 PM" src="https://github.com/user-attachments/assets/fba89e70-daad-46f9-8915-561270009d47" />

I added a red color overlay and wrote a vignette function. I then created a scribble texture for the vignette edges and animated the texture similarly to how I did in my paper post process effect. 

<img width="800" alt="Screenshot 2024-12-12 at 6 25 39 PM" src="https://github.com/user-attachments/assets/f5c37216-e3bc-4392-908b-81f1efb4e84c" />

Finally, this is how my final product turned out!

https://github.com/user-attachments/assets/c75fad0e-060d-4439-a10e-2fa319b52a18


