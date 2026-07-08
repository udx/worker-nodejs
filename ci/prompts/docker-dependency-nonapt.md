Non-apt dependency rules:
- Use `dependencies.non_apt.pins` and `dependencies.non_apt.urls` from the dependency report as the starting inventory of Dockerfile-owned non-apt candidates.
- For `NODE_VERSION`, check the official Node.js release index and keep the latest stable LTS release from the same active LTS line unless the Dockerfile or repo docs explicitly require a different major version.
- Preserve the UDX Worker base image tag already selected by the deterministic updater unless clear upstream evidence shows a newer stable `udx/worker` release.
- Include the upstream source URL for every non-apt update in the changelog.
- Leave pins unchanged when the upstream source cannot be identified, cannot be checked, is ambiguous, or does not clearly show a newer stable release/version.
- Keep dynamically installed dependencies unpinned unless Dockerfile already pins them; mention them in the changelog only.
