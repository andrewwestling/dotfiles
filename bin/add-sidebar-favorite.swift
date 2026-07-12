// Add a folder to Finder's sidebar Favorites.
// Usage: swift bin/add-sidebar-favorite.swift /path/to/folder
// Uses the LSSharedFileList API (deprecated by Apple but still functional;
// it's the same API the retired `mysides` tool used).
// Note: the kLSSharedFileListItemLast sentinel crashes under Swift bridging,
// so we insert after the real last item from the snapshot instead.
import Foundation
import CoreServices

guard CommandLine.arguments.count == 2 else {
    print("usage: add-sidebar-favorite.swift <folder>")
    exit(64)
}
let url = URL(fileURLWithPath: (CommandLine.arguments[1] as NSString).expandingTildeInPath)
guard let list = LSSharedFileListCreate(nil, kLSSharedFileListFavoriteItems.takeUnretainedValue(), nil)?.takeRetainedValue() else {
    print("error: could not open Favorites list"); exit(1)
}

var seed: UInt32 = 0
let items = (LSSharedFileListCopySnapshot(list, &seed)?.takeRetainedValue() as? [LSSharedFileListItem]) ?? []

for item in items {
    if let itemURL = LSSharedFileListItemCopyResolvedURL(item, 0, nil)?.takeRetainedValue() as URL?,
       itemURL.standardizedFileURL == url.standardizedFileURL {
        print("already in Favorites: \(url.path)"); exit(0)
    }
}

guard let last = items.last else {
    print("error: Favorites list is empty; add one item in Finder first"); exit(1)
}
if LSSharedFileListInsertItemURL(list, last, nil, nil, url as CFURL, nil, nil) != nil {
    print("added to Favorites: \(url.path)")
} else {
    print("error: failed to add \(url.path)"); exit(1)
}
