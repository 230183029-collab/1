# Wanderlist

A small travel-planning app built with **Swift + UIKit, fully programmatic** (no storyboards, no SwiftUI).

- **Explore tab** – destinations grouped by region in a `UICollectionView`. Tap a card to open a detail screen.
- **Packing tab** – a sectioned checklist in a `UITableView`. Destination detail screens (and the touch-and-hold menu) can add climate-specific items to it.

## Run it

1. Open `Wanderlist.xcodeproj` in Xcode 14 or newer.
2. Pick any iPhone simulator (iOS 15+).
3. Press **Cmd+R**. No signing team is needed for the simulator.

## Requirements checklist

### UITableView (`PackingListViewController.swift`) – 16 methods

| Method | Purpose |
| --- | --- |
| `numberOfSections(in:)` | One section per packing category |
| `numberOfRowsInSection` | Item count per category |
| `cellForRowAt` | Configures the custom `PackingItemCell` |
| `titleForFooterInSection` | "3 of 4 packed" summary per category |
| `canEditRowAt` | Every row can be deleted |
| `commit editingStyle` | Performs the delete (edit mode) |
| `canMoveRowAt` | Every row can be reordered |
| `moveRowAt` | Persists the new order in the store |
| `viewForHeaderInSection` | Custom `CategoryHeaderView` with icon and count |
| `heightForHeaderInSection` | Header height |
| `heightForRowAt` | Rows with a note are taller |
| `didSelectRowAt` | Pack / unpack the item |
| `trailingSwipeActionsConfigurationForRowAt` | Swipe left: Delete, Note |
| `leadingSwipeActionsConfigurationForRowAt` | Swipe right: Pack / Unpack (full swipe) |
| `targetIndexPathForMoveFromRowAt` | Keeps dragged rows inside their own category |
| `contextMenuConfigurationForRowAt` | Touch and hold: change quantity |

### UICollectionView (`DestinationsViewController.swift`) – 14 methods

| Method | Purpose |
| --- | --- |
| `numberOfSections(in:)` | One section per region (empty regions hidden) |
| `numberOfItemsInSection` | Destinations in the region |
| `cellForItemAt` | Configures the custom `DestinationCell` |
| `viewForSupplementaryElementOfKind` | Region header with place count |
| `didSelectItemAt` | Pushes `DestinationDetailViewController` |
| `didHighlightItemAt` / `didUnhighlightItemAt` | Press-down scale feedback |
| `willDisplay` | One-time fade/slide entrance animation |
| `contextMenuConfigurationForItemAt` | Favorite a place or add its packing list |
| `sizeForItemAt` | First card full width, others two per row |
| `insetForSectionAt` | Section padding |
| `minimumLineSpacingForSectionAt` | Row spacing |
| `minimumInteritemSpacingForSectionAt` | Column spacing |
| `referenceSizeForHeaderInSection` | Header size |

### Other requirements

- **Data**: 12 destinations in 4 regions, 18 packing items in 5 categories.
- **Interaction**: navigation to a detail screen, favorite toggle, "Favorites" filter, shuffle button, pack/unpack, swipe-to-delete, edit-mode reordering, add item (bar button menu), edit note, quantity menu, bulk actions, tab badge showing items left to pack.
- **Custom appearance**: gradient cards with shadows and SF Symbols, padded pill labels, custom header views, strikethrough on packed items, progress bar, toast messages.

## Project layout

```
Wanderlist/
  AppDelegate.swift, SceneDelegate.swift      app + scene setup (no storyboard)
  MainTabBarController.swift                  tabs and packing badge
  Models.swift, PackingStore.swift            data
  DestinationsViewController.swift            UICollectionView screen
  DestinationCell.swift                       collection cell
  DestinationDetailViewController.swift       detail screen
  PackingListViewController.swift             UITableView screen
  PackingItemCell.swift                       table cell
  Views.swift                                 theme, headers, shared views
```
