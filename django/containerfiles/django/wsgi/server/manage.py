#!/usr/bin/env python
import os
import sys

if __name__ == "__main__":
    # GETTING-STARTED: change 'webapp' to your project name:
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "webapp.settings")

    from django.core.management import execute_from_command_line

    execute_from_command_line(sys.argv)
