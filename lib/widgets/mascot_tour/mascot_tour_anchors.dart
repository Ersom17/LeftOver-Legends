// lib/widgets/mascot_tour/mascot_tour_anchors.dart
//
// Global registry of GlobalKeys that mark the on-screen anchors the
// mascot tour points at. A target widget wraps itself in a Builder and
// assigns its GlobalKey via [MascotAnchors.register] so the overlay can
// later measure the target's rect.

import 'package:flutter/material.dart';

class MascotAnchorIds {
  static const addItemFab = 'add_item_fab';
  static const filterSegmented = 'filter_segmented';
  static const generateRecipes = 'generate_recipes';
  static const navRecipes = 'nav_recipes';
  static const navLearn = 'nav_learn';
  static const navRewards = 'nav_rewards';
  static const navProfile = 'nav_profile';
  static const helpButton = 'help_button';

  // Add-item walkthrough
  static const sourceManual = 'source_manual';
  static const addItemSave = 'add_item_save';

  // Recipe walkthrough
  static const recipeOptionsConfirm = 'recipe_options_confirm';
  static const recipeCardFirst = 'recipe_card_first';
  static const recipeYoutube = 'recipe_youtube';
}

class MascotAnchors {
  static final Map<String, GlobalKey> _keys = {};

  static GlobalKey keyFor(String id) {
    return _keys.putIfAbsent(id, () => GlobalKey(debugLabel: 'mascot:$id'));
  }

  static Rect? rectFor(String id) {
    final key = _keys[id];
    final ctx = key?.currentContext;
    if (ctx == null) return null;
    final render = ctx.findRenderObject();
    if (render is! RenderBox || !render.attached) return null;
    final offset = render.localToGlobal(Offset.zero);
    return offset & render.size;
  }
}
