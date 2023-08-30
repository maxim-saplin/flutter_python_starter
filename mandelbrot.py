import time
import numpy as np 
import matplotlib.pyplot as plt

def generate_fractal(x_min, x_max, y_min, y_max, image_size, max_iterations, z0=0):
    
    # Create grid
    x_values = np.linspace(x_min, x_max, image_size)
    y_values = np.linspace(y_min, y_max, image_size)
    xx, yy = np.meshgrid(x_values, y_values)
    
    # Initialize output image
    image = np.zeros((image_size, image_size))
    
    # Compute fractal set
    for i in range(image_size):
        for j in range(image_size):
            c = xx[i,j] + 1j*yy[i,j]
            z = z0
            for k in range(max_iterations):
                z = z**2 + c
                if abs(z) > 2:
                    break
            image[i,j] = k
        
    return image

def display_fractal(image, x_min, x_max, y_min, y_max):   
    plt.imshow(image.T, cmap='plasma', extent=[x_min, x_max, y_min, y_max])
    plt.xlabel('Re(c)')
    plt.ylabel('Im(c)')
    plt.show()
    
# Generate and display Mandelbrot set    
# mandel = generate_fractal(-2, 0.5, -1.25, 1.25, 500, 255)
# display_fractal(mandel, -2, 0.5, -1.25, 1.25)

print('Generating Julia set... ', end='')
start_time = time.time()

# Generate and display Julia set
julia = generate_fractal(-1.5, 1.5, -1.5, 1.5, 500, 255, z0=-0.4 + 0.6j)

end_time = time.time()
elapsed_time = end_time - start_time

print("{:.2f}".format(elapsed_time)+ 'ms')

print('Displaying Julia set... ')
display_fractal(julia, -1.5, 1.5, -1.5, 1.5)
print('Done')