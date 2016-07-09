#!/usr/bin/env python

from setuptools import setup

setup(
    # GETTING-STARTED: set your app name:
    name='DockerDjangoWebsite',
    # GETTING-STARTED: set your app version:
    version='1.0',
    # GETTING-STARTED: set your app description:
    description='DockerDjangoWebsite',
    # GETTING-STARTED: set author name (your name):
    author='YOUR NAME',
    # GETTING-STARTED: set author email (your email):
    author_email='YOUR EMAIL',
    # GETTING-STARTED: set author url (your url):
    url='YOUR URL',
    # GETTING-STARTED: define required django version:
    install_requires=[
        'Django',
        'slackclient',
        'uuid',
        'requests',
        'sphinx_bootstrap_theme'
    ],
    dependency_links=[
        'https://pypi.python.org/simple/django/'
    ],
)
