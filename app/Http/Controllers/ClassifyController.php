<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ClassifyController extends Controller
{
    public function classify(Request $request): JsonResponse
    {
        // GATE 1: name must be present and non-empty → 400
        if (!$request->has('name') || trim($request->query('name', '')) === '') {
            return response()->json([
                'status'  => 'error',
                'message' => 'The name parameter is required and cannot be empty.',
            ], 400);
        }

        // GATE 2: name must be a string, not an array → 422
        $nameParam = $request->query('name');

        if (!is_string($nameParam)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'The name parameter must be a string.',
            ], 422);
        }

        $name = trim($nameParam);

        // CALL GENDERIZE API
        try {
            $response = Http::timeout(15)
                ->withOptions([
                    'verify'          => false,
                    'connect_timeout' => 10,
                ])
                ->get('https://api.genderize.io', [
                    'name' => $name,
                ]);

            if ($response->serverError()) {
                throw new \Exception('Genderize API returned a server error: ' . $response->status());
            }

        } catch (\Illuminate\Http\Client\ConnectionException $e) {
            Log::error('Genderize API connection failed: ' . $e->getMessage());

            return response()->json([
                'status'  => 'error',
                'message' => 'Unable to reach the gender prediction service. Please try again later.',
            ], 502);

        } catch (\Exception $e) {
            Log::error('Genderize API error: ' . $e->getMessage());

            return response()->json([
                'status'  => 'error',
                'message' => 'An error occurred while contacting the gender prediction service.',
            ], 502);
        }

        // PARSE RESPONSE
        $data   = $response->json();
        $gender = $data['gender'] ?? null;
        $count  = $data['count']  ?? 0;

        // EDGE CASE: no prediction available for this name
        if ($gender === null || $count === 0) {
            return response()->json([
                'status'  => 'error',
                'message' => 'No prediction available for the provided name',
            ], 200);
        }

        // TRANSFORM DATA
        $probability = (float) ($data['probability'] ?? 0);
        $sampleSize  = (int) $count;
        $isConfident = ($probability >= 0.7) && ($sampleSize >= 100);
        $processedAt = now()->utc()->toISOString();

        // SUCCESS
        return response()->json([
            'status' => 'success',
            'data'   => [
                'name'         => $name,
                'gender'       => $gender,
                'probability'  => $probability,
                'sample_size'  => $sampleSize,
                'is_confident' => $isConfident,
                'processed_at' => $processedAt,
            ],
        ], 200);
    }
}
