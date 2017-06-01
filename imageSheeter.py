# author: Sebastian Coraccio
# date: 2017-05-10
# description:
# This Program will take a directory and make a image sheet out of the images
# within the folder.
#
# Images must be numbered so they are read in the correct order.
# Only png images can be in the directory
# All images need to have the same height and width

from PIL import Image
import os

def createSheet():
  image_files = []

  print("""Welcome to the Image Sheet Creator.
This Program will take a directory and make a image sheet out of the images
within the folder.
NOTE: Images must be numbered so they are read in the correct order.
NOTE: Only png images can be in the directory
NOTE: All images need to have the same height and width
""")

  directory = input("Enter the name of the directory which holds the .png files. ")

  # Get all files from the directory
  image_files = os.listdir(directory)

  # The first image will be used for default height and width values
  info_image = Image.open(directory + "/" + image_files[0])
  width = info_image.width
  height = info_image.height

  # Images are stitched together horizontally, so calculate the sheet width
  sheet_width = width * len(image_files)
  sheet_height = height

  sheet = Image.new('RGBA', (sheet_width, sheet_height))

  # Loop through the images and add them the sheet
  counter = 0
  for image in image_files:
    img = Image.open(directory + "/" + image)

    if not img.width == width and not img.height == height:
      print(image + " does not have the correct dimensions.")
      return

    sheet.paste(im=img, box=(width * counter,0))
    counter += 1

  file_name = directory + "_image_sheet.png"
  sheet.save(file_name)

  print("\nThe image sheet has been saved to " + file_name)
  print("Here are the sheetOptions for use with Corona SDK:\n")

  # Create the sheetOptions variable needed by Corona SDK
  corona_sheet = "local sheetOptions =\n{{\n\twidth = {0}\n\theight = {1}\n\tnumFrames = {2}\n}}".format(width, height, len(image_files))
  print(corona_sheet)

  print("\nAll done. Exiting Image Sheeter.")

if __name__ == "__main__":
  createSheet()