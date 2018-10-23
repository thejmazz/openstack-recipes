# Base Images

This step is to add base images to glance.

You may choose to skip this step if your admin has already made some images
publically available, but it is highly recommended to use this approach even if
that is the case.

You may wish to tag your images. At a minimum, you should set `os_distro`
(NOTE! Must be lowercase!), `os_type`, and `os_version`.

Later we can retrieve these images using a Terraform data source and querying
via properties, or by hardcoding the image name.
