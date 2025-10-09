# Get build image
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

# Copy source
COPY . ./

# Bring in metadata via --build-arg for build
ARG IMAGE_VERSION=unknown

# Restore packages
RUN dotnet restore

# Build project and run tests
RUN dotnet test -v m /property:WarningLevel=0

# Publish release project
RUN dotnet publish -v m /property:WarningLevel=0 -c Release --property:PublishDir=/app/publish/

# Copy release-publish.bash script
RUN cp /app/release-publish.bash "/app/publish/"

# Copy actual build script
RUN cp /app/build.bash "/app/publish/"

# Get runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS publish

WORKDIR /app

# Bring in metadata via --build-arg to publish
ARG BRANCH=unknown
ARG IMAGE_CREATED=unknown
ARG IMAGE_REVISION=unknown
ARG IMAGE_VERSION=unknown

# Configure image labels
LABEL branch=$BRANCH \
    maintainer="Maricopa County Library District developers <development@mcldaz.org>" \
    org.opencontainers.image.authors="Maricopa County Library District developers <development@mcldaz.org>" \
    org.opencontainers.image.created=$IMAGE_CREATED \
    org.opencontainers.image.description="Build script test project" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.revision=$IMAGE_REVISION \
    org.opencontainers.image.source="https://github.com/MCLD/buildscript" \
    org.opencontainers.image.title="Build scrip test project" \
    org.opencontainers.image.vendor="Maricopa County Library District" \
    org.opencontainers.image.version=$IMAGE_VERSION

# Default image environment variable settings
ENV org.opencontainers.image.created=$IMAGE_CREATED \
    org.opencontainers.image.revision=$IMAGE_REVISION \
    org.opencontainers.image.version=$IMAGE_VERSION

# Copy source
COPY --from=build "/app/publish/" .

# Set entrypoint
ENTRYPOINT ["dotnet", "buildscript.dll"]
