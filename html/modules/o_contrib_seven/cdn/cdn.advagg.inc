<?php

/**
 * Implement hook_advagg_context_alter().
 */
function cdn_advagg_context_alter(&$original, $aggregate_settings, $mode) {
  if ($mode == 0) {
    // Save original context.
    $original[CDN_MODE_VARIABLE] = variable_get(CDN_MODE_VARIABLE, CDN_MODE_BASIC);
    $original[CDN_BASIC_FARFUTURE_VARIABLE] = variable_get(CDN_BASIC_FARFUTURE_VARIABLE, CDN_BASIC_FARFUTURE_DEFAULT);
    $original[CDN_HTTPS_SUPPORT_VARIABLE] = variable_get(CDN_HTTPS_SUPPORT_VARIABLE, FALSE);
    $original[CDN_STATUS_VARIABLE] = variable_get(CDN_STATUS_VARIABLE, CDN_DISABLED);

    // Set context for file_create_url()/cdn_file_url_alter().
    $GLOBALS['conf'][CDN_MODE_VARIABLE] = $aggregate_settings['variables'][CDN_MODE_VARIABLE];
    $GLOBALS['conf'][CDN_BASIC_FARFUTURE_VARIABLE] = $aggregate_settings['variables'][CDN_BASIC_FARFUTURE_VARIABLE];
    $GLOBALS['conf'][CDN_HTTPS_SUPPORT_VARIABLE] = $aggregate_settings['variables'][CDN_HTTPS_SUPPORT_VARIABLE];
    $GLOBALS['conf'][CDN_STATUS_VARIABLE] = $aggregate_settings['variables'][CDN_STATUS_VARIABLE];
    // Disable CDN if cdn_check_drupal_path is FALSE.
    if (!$aggregate_settings['variables']['cdn_check_drupal_path']) {
      $original[CDN_STATUS_VARIABLE] = CDN_DISABLED;
    }

    // Handle HTTPS.
    if ($aggregate_settings['variables']['cdn_request_is_https'] && !cdn_request_is_https()) {
      if (isset($_SERVER['HTTPS'])) {
        $original['HTTPS'] = $_SERVER['HTTPS'];
      }
      else {
        $original['HTTPS'] = FALSE;
      }
      $_SERVER['HTTPS'] = 'on';
    }
  }
  elseif ($mode == 1) {
    // Set context back.
    $GLOBALS['conf'][CDN_MODE_VARIABLE] = $original[CDN_MODE_VARIABLE];
    $GLOBALS['conf'][CDN_BASIC_FARFUTURE_VARIABLE] = $original[CDN_BASIC_FARFUTURE_VARIABLE];
    $GLOBALS['conf'][CDN_HTTPS_SUPPORT_VARIABLE] = $original[CDN_HTTPS_SUPPORT_VARIABLE];
    $GLOBALS['conf'][CDN_STATUS_VARIABLE] = $original[CDN_STATUS_VARIABLE];

    // Handle HTTPS.
    if (isset($original['HTTPS']) && !is_null($original['HTTPS'])) {
      $_SERVER['HTTPS'] = $original['HTTPS'];
    }
  }
}
