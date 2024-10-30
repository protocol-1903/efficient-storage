[![](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Fefficient-storage&style=for-the-badge)](https://mods.factorio.com/mod/efficient-storage) [![](https://img.shields.io/badge/Discord-Community-blue?style=for-the-badge)](https://discord.gg/K3fXMGVc4z) [![](https://img.shields.io/github/issues/protocol-1903/efficient-storage?label=Bug%20Reports&style=for-the-badge)](https://github.com/protocol-1903/efficient-storage/issues) [![](https://img.shields.io/github/issues-pr/protocol-1903/efficient-storage?label=Pull%20Requests&style=for-the-badge)](https://github.com/protocol_1903/efficient-storage/pulls)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/B0B7145X5R)

BETA VERSION: CAN BREAK SAVES

longer description to be made later :)


# TECHNICAL DESCRIPTION

When inserters check a container, they need to check every single slot for items. If the slot is locked (red bar in chests) then it still needs to be checked when an inserter is removing items, but not inserting. This mod attempts to remedy that issue by reducing the container size to a more reasonable amount. Normal containers have a search complexity of o(n) where n is the number of slots in the container. This mod reduces that to o(2). Currently it only supports single-item storage alternatives, but I will eventually add support for multi-item storage. That complexity will be o(2*r) where r is the number of different items. I will probably test and limit the number of different items based on the diminishing returns of the system.

If anyone has suggestions for how to make the system faster and more efficient, you are welcome to open a PR or leave a comment.
