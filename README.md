ImageCompare
============

A command line image compare tool. It compares the color of two images pixel by pixel (RGBA). The program calculates the quadratic mean distance between two pixels. If the distance is below a given threshold then the pixels are treated as equal. The program produces a diff-image where equal pixels are grayed and unequal pixels are painted in red. In addition the program ignores areas which are filled with a mask-color (taken form the top left pixel) in the reference image. 


Example
=======

| Reference Image | To Compare Image | Mask Image | Difference Image |
| --------------- | ---------------- | ---------- | ---------------- |
| ![reference-image](ExampleImages/smaller/reference-image.png "Reference Image") | ![to-compare-image](ExampleImages/smaller/to-compare-image.png "To compare Image") | ![to-compare-image](ExampleImages/smaller/mask-image.png "Mask Image") | ![difference-image](ExampleImages/smaller/difference-image.png "Difference Image") |




Usage
=====

After compiling, you can put the binary where you want.

```
Usage:   ImageCompare [options] <compare-file> <reference-file> <difference-file> [<mask-file>]

Options: -h           print this help info
         -v           be more verbose
         -t <value>   value is a integer interpreted as maximum distance per color component
                      The resulting quadratic mean error will be calculated by 3*(value*value)
                      Default is 8.

Return codes:  0      both images are equal
              -1      images are not equal
              -2      error because the images have different sizes
              -3      error because IO problems (mostly file not found)
              -4      error because wrong arguments used

Note: If a mask-file is specified then the color of the top left corner will be used to mask areas
      where the program doesn't compare pixels!

Info: Source for this program at https://github.com/meknil/ImageCompare
      Using ANImageBitmapRep (see https://github.com/unixpickle/ANImageBitmapRep)
```


Thanks to
=========

This tool is based on the [ANImageBitmapRep](https://github.com/unixpickle/ANImageBitmapRep) project created by Alex Nichol (unixpickle).


License
=======

This tool and the sources are published under MIT License.

 
FAQ
===

### Why not using ImageMagick?

Yes, ImageMagick is also useable to compare images. The `compare` command offers a threshold option and is able to produce a diff-image too. But I found it really complicated to ignore areas. I like the idea to just filling areas in the reference image more than determining them by there coordinates. Maybe, there exists a proper script for that problem but I don't like to read long documents. Instead I just wrote this program which fulfils my needs.  


