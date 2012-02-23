# WSImageDownload

## Why?

There are quite a few libraries that provide a UIImageView category to allow you to easily download and set images.  I wanted to create one that would allow a little more flexibility around animating existing images out and the new image in.  I also wanted to package the main logic into a single service so that doing the same for UIButtons or any other async image downloads would be really simple.

## How

### UIImageView

At it's simplest, you can do this:

	[imageView setImageWithURL:url]

But you can also do this:

	[imageView setImageWithURL:url
             		animateOut:^{
						// Only called if the image is not cached and arrives sometime after initial invocation
						imageView.alpha = 0;
					}
              		 animateIn:^{
						// Called after the image is set on the imageView
						imageView.alpha = 1;
					}
               		  duration:0.3];

If there is an existing download for the imageView, it is cancelled.

### UIView

There is also a category on UIView to allow you to fetch and image and customise how it is animated and set

	[aButton downloadUrl:url
			  animateOut:^{
					aButton.alpha = 0;
				}
			   animateIn:^{
					aButton.alpha = 1;
				}
				configure:^(UIImage *image, BOOL fromCache) {
					[aButton setImage:image forState:UIControlStateNormal];
				}
				duraction:0.3];
				

If there is an existing download for the view, it is cancelled.
				
### Lower-level

The core service is WSImageDownload which can be used to fetch arbitrary data, but is mostly useful for fetching images:

	[[WSImageDownload sharedService] downloadUrl:url 
										   owner:self
										 asImage:^(UIImage *image, BOOL fromCache) {
											// Do something, like update an address book contact
										} failure:^(NSError *error) {
											// Woops, maybe do someting with this error
										}];
										
You can explicitly cancel operations for an owner as follows:

	[[WSImageDownload sharedService] cancelDownloadsForOwner:self];
	
It's probably a good idea to do that on dealloc of the owner


## Who

Made by @rayh 
