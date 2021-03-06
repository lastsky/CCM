name 'linux_server'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'MIT'
description 'Installs/Configures linux_server'
long_description 'Installs/Configures linux_server'
version '0.1.11'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'mysql','~> 8.5'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/linux_server/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/linux_server'
