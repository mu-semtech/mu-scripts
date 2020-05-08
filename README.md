# mu-scripts

This image serves as a basis for mu-cli script. See http://github.com/mu-semtech/mu-cli for more information.

The mu-scripts image serves as a minimal container which makes it easy to share scripts with mu-cli.  Some functionality is offered to help write versioned scripts.

## Getting started

_Getting started with mu-scripts_

This image serves as a support service for mu-cli.  The best introduction to mu-scripts is to [http://github.com/mu-semtech/mu-cli/#getting-started](get started with mu-cli).

## How-to guides

_Specific guides how to apply this container_

### Embedded in your project

Your project might have common project-specific scripts.  Copying a backup over to an external system or switching the default docker-compose file.  Scripts can be embedded in a project.  You can use this image with minimal overhead to write scripts embedded in your mu-project.

#### Add the service to your mu-project

The service needs to be added to your docker-compose.yml file.

The sensible default name for a service containing project-specific scripts is `project-scripts`, the sensible default folder in which to place the project-specific scripts is `scripts/project`.

As such, the docker-compose.yml service description becomes:

    project-scripts:
      image: semtech/mu-scripts:1.0.0
      volumes:
        - ./scripts/project:/app/scripts/
      restart: never

You can now add your `config.json` and your scripts into this folder.  More info at https://github.com/mu-semtech/mu-cli


### Versioned scripts for your project

Some scripts can be reused across projects, but don't belong to a single service.  You could have a backup restore facility which ties in to your local infrastructure.  The backup restore script may work for multiple projects, but only within your organization.  In such case it can make sense to provide these scripts as a versioned container.

In order to create the new image we create a folder and add a `Dockerfile` to that.  The contents of this file should look like:

    FROM semtech/mu-scripts:1.0.0

Once we have this in place, we can start adding scripts.  The `config.json` lives in the root of the project.  We expect to have one script in there for this example.

With one script, our `config.json` could look like:

    {
      "version": "0.1",
      "scripts": [
        {
          "documentation": {
            "command": "restore-zero-backup",
            "description": "Backup from Zero Up Icy Backup",
            "arguments": []
          },
          "environment": {
            "image": "ubuntu",
            "interactive": false,
            "script": "zero-backup/run.sh"
          },
          "mounts": {
            "app": "/data/app/"
          }
        }
      ]
    }

Next up, we can add the script in `./zero-backup/run.sh`.

    #!/bin/bash
    echo "I have no clue what ZeroBackup would be, but I can't really restore."

You can now make an automated or local build and add it to your project.

    docker build . -t "zerocomp/backup-scripts

And add it as a service:

    backup-scripts:
      image: zerocomp/backup-scripts
      restart: never

Now we can trigger the script:

    mu script zerocomp restore-zero-backup

You're done.  Versioned scripts in your projects.

## Reasoning

_Background information about the approach we took_

### Timeout before exit

The container sleeps for 60 seconds before exiting.  Reasoning for this is that you might accidentally set a `restart: always` on all of your containers when running in production.  This is a good practice, but it would make this container spin up continuously.  60 seconds seems to provide a good balance between discovery and minimum system overhead.

### Minimal container

One could argue that this container should offer a bunch of support for writing scripts.  We chose not to do this because the specific needs for various scripts would be different.  We still want the image name to reflect what this container is for, and that is hosting scripts.  Other images can be constructed which will write the scripts to the right location.

## API

_Provided application interface_

### Extending this image

When extending the image, the `ONBUILD` command will at least copy:

- the `/config.json` and place it in `/app/scripts/config.json`.
- folders containing scripts, and place the folders in `/app/scripts/`.

Other files and folders may, but are not guaranteed, to be copied over.  As such, this behavior may change without a major version bump.
