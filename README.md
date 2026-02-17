# Custom Flags - PrestaShop 8+ Module

Add custom flags and labels to your products. Display badges like **Bestseller**, **Eco**, **Limited Edition**, directly on product images - both on product listings and product detail pages.

## Features

- Create unlimited custom flags with configurable name, background color, and text color
- Live preview of the flag while editing in the admin panel
- Assign flags to products via AJAX-powered search (search by name or reference)
- Multi-select product assignment - assign multiple products at once
- Flags are displayed as overlays on product images (centered at the top)
- When a product has a custom flag, native PrestaShop flags (e.g. "On Sale!") are automatically hidden
- Fully responsive - flags adapt to mobile screens
- Position ordering - control the display order of multiple flags
- Toggle active/inactive state per flag
- Clean uninstall - removes all database tables and admin tabs

## Requirements

- PrestaShop **8.0.0** or higher
- PHP 7.4+

## Installation

1. Copy the `customflags` folder into your PrestaShop `modules/` directory
2. Go to **Back Office → Modules → Module Manager**
3. Search for "Custom Flags" and click **Install**

## Usage

### Creating a Flag

1. Go to **Back Office → Catalog → Custom Flags**
2. Click the **+** button to create a new flag
3. Enter the flag name, choose background and text colors
4. Set the position (lower = displayed first) and active status
5. Click **Save**

### Assigning Products

1. Open an existing flag (edit mode)
2. Use the search bar to find products by name or reference
3. Select one or more products from the results
4. Click **Assign Selected**
5. To remove a product, click the trash icon next to it

## File Structure

```
customflags/
├── customflags.php                          # Main module class
├── index.php                                
├── controllers/
│   └── admin/
│       ├── AdminCustomFlagsController.php   # Admin controller
│       └── index.php
├── views/
│   ├── css/
│   │   ├── admin.css                        # Admin panel styles
│   │   ├── front.css                        # Front-office styles
│   │   └── index.php
│   ├── js/
│   │   ├── admin.js                         # Admin panel JavaScript
│   │   └── index.php
│   └── templates/
│       ├── admin/
│       │   ├── form.tpl                     # Flag create/edit form
│       │   ├── list.tpl                     # Flags list view
│       │   └── index.php
│       └── hook/
│           ├── product_flags.tpl            # Front-office flag display
│           └── index.php
```

## Hooks

| Hook | Description |
|------|-------------|
| `displayProductListReviews` | Displays flags on product listing miniatures |
| `displayProductAdditionalInfo` | Displays flags on product detail pages |
| `actionFrontControllerSetMedia` | Loads front-office CSS |

## Database Tables

| Table | Description |
|-------|-------------|
| `ps_custom_flag` | Stores flag definitions (name, colors, position, active) |
| `ps_custom_flag_product` | Many-to-many relation between flags and products |

## Modification

You can edit CSS file (controllers/views/css/front.css) to adjust flags to your own preferences.

## License

MIT

## Author

[Astrodesign.pl](https://astrodesign.pl) - [github.com/kn00pers](https://github.com/kn00pers)
