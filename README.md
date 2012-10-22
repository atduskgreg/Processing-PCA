## Processing-PCA

Examples of using Principle Component Analysis in Processing with [pca_transform](https://github.com/mkobos/pca_transform). 

### Using PCA with basic numerical data

<a href="http://www.flickr.com/photos/unavoidablegrain/8112912665/" title="PCA with basic data by atduskgreg, on Flickr"><img src="http://farm9.staticflickr.com/8195/8112912665_83202bcb86.jpg" width="479" height="500" alt="PCA with basic data"></a>

This example demonstrates the most basic application of PCA to find the main axes of variation amongst some random 2D points.

### Using PCA with OpenCV to find object orientation

<a href="http://www.flickr.com/photos/unavoidablegrain/8074895164/" title="PCA and OpenCV to find object orientation in Processing by atduskgreg, on Flickr"><img src="http://farm8.staticflickr.com/7121/8074895164_86852dce43.jpg" width="500" height="392" alt="PCA and OpenCV to find object orientation in Processing"></a>

This example uses OpenCV to reduce an image of a pen on a white background to a binary image (each pixel 100% white or black). It then treats these pixels as points to perform PCA. The resulting principle components make up the axes of orientation of the object.

### Using PCA with OpenCV for live object orienation

<iframe src="http://player.vimeo.com/video/51174493?byline=0&amp;portrait=0&amp;color=ffffff" width="500" height="313" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe> <p><a href="http://vimeo.com/51174493">PCA Object Orientation Tracking with Processing</a> from <a href="http://vimeo.com/user1249829">Greg Borenstein</a> on <a href="http://vimeo.com">Vimeo</a>.</p>

This example improves on the one above by applying the same technique to live video to find object orientation interactively.


### Using PCA with Kinect to find Head and Hand Orientation

<a href="http://www.flickr.com/photos/unavoidablegrain/8111539204/" title="PCA with Kinect for head orientation by atduskgreg, on Flickr"><img src="http://farm9.staticflickr.com/8465/8111539204_ff5ae2bb5d.jpg" width="500" height="386" alt="PCA with Kinect for head orientation"></a>

<a href="http://www.flickr.com/photos/unavoidablegrain/8111539238/" title="PCA with Kinect for hand orientation by atduskgreg, on Flickr"><img src="http://farm9.staticflickr.com/8473/8111539238_b768e78912.jpg" width="500" height="386" alt="PCA with Kinect for hand orientation"></a>

This example uses the [SimpleOpenNI Kinect library](http://code.google.com/p/simple-openni/) to access the depth points and joint data from the Kinect. It finds all of the depth points within a bounding box around a given joint (in this case, the head) and then conducts PCA on those points in order to find the orientation of the joint. This gives you head or hand orientation, which is otherwise not available from the Kinect joint data.