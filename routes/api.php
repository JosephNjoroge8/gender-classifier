<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ClassifyController;

Route::get('/ping', function () {
    return response()->json(['status' => 'ok']);
});

Route::get('/classify', [ClassifyController::class, 'classify']);
