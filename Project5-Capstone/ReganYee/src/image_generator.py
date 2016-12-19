from keras.preprocessing.image import ImageDataGenerator, array_to_img, img_to_array, load_img
import os
import glob

datagen = ImageDataGenerator(
        rotation_range=40,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='nearest')

path = os.path.join('..', 'input', 'train_o', '2', '*.png')
files = glob.glob(path)

for fl in files:

    img = load_img(fl)  # this is a PIL image
    x = img_to_array(img)  # this is a Numpy array with shape (3, 150, 150)
    x = x.reshape((1,) + x.shape)  # this is a Numpy array with shape (1, 3, 150, 150)

    # the .flow() command below generates batches of randomly transformed images
    # and saves the results to the `preview/` directory
    i = 0
    prefix = os.path.basename(fl)
    for batch in datagen.flow(x, batch_size=1,
                              save_to_dir='preview', save_prefix=prefix, save_format='png'):
        i += 1
        if i > 5:
            break  # otherwise the generator would loop indefinitely