# HW 4: *3D Stylization*

https://github.com/user-attachments/assets/05ee418f-9683-430d-8a05-b0e54823f1df

## Overview

For this project, I picked a piece of 2D concept art and recreated it as a 3D stylized scene in unity.

## Concept Art

| ![gyarados](https://github.com/user-attachments/assets/ed07f4aa-401b-4a6e-af57-3546c5cfb16a) |
|:--:|
| [Original](https://missypena.tumblr.com/post/140319090313/the-great-wave-off-kanto-full-composition) by Missy Peña | 

I wanted to do something Pokemon-related and this art caught my eye!

---
## Improved Surface Shader

For my surface shader, I implemented multiple light support following the tutorial. I also implemented rim lighting as an additional lighting feature, as seen here.

![image](https://github.com/user-attachments/assets/a5d3b5ce-eb38-4019-975e-820238457e79)

I also put a watercolor texture on the shadow that uses the object's UV's:

![image](https://github.com/user-attachments/assets/a0191b39-595c-4205-984a-3db728bae48c)

![image](https://github.com/user-attachments/assets/c9dc58e3-c114-43be-94f5-1a301400bb95)

## Special Surface Shader

I implemented a vertex animation to make the gyarados and magikarp bob up and down in the water. It also has a time shift parameter so I can make them bob out of sync.

![image](https://github.com/user-attachments/assets/838c3a17-a356-44cc-8fec-dcb3157f691b)

## Outlines
These post-process outlines were generated using depth buffer sobel outlines, which detect places where there are strong differences in depth. This is done using 3x3 convolution kernels, which detect horizontal and vertical changes. I decided to base the lines off depth rather than color or normals, since I only wanted the outline to exist between separate objects.

For the outlines, I also couldn't put outlines on a transparent object (the water) so I made the water unaffected by scene lighting.

![image](https://github.com/user-attachments/assets/1f58075c-1d62-4afa-b31c-860e799e26ef)

## Full Screen Post Process Effect
I created a post-process effect to color-correct the result, and also applied an animated overlay to get a nice paper-y texture. 

![image](https://github.com/user-attachments/assets/8738f872-b19f-4bd5-9141-1de61076fc9c)


---
## Create a Scene
For my scene, I downloaded some Pokemon models and posed them around. I also created a plane in blender and applied some noise on it to get a wave shape.

## Interactivity
I created a few additional post-process filters: A pixel filter, and a tone-mapping filter to get the same colors as Pokemon Yellow.
![image](https://github.com/user-attachments/assets/11ceec89-444b-4723-bdc2-5dd93d0235ac)

## Extra Credit
I implemented a water shader as the environment!

![image](https://github.com/user-attachments/assets/cf0ec445-d59c-43bc-ae8a-7eab48cb3c45)
