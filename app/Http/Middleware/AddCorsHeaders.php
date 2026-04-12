<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AddCorsHeaders
{
    /**
     * Add CORS headers to every response — including error responses.
     *
     * Story: This is the security guard at the exit door.
     * Every single visitor who leaves the building gets a stamp
     * that says "this bureau welcomes cross-origin visitors."
     * It doesn't matter if the visit was successful or rejected.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $response->headers->set('Access-Control-Allow-Origin', '*');
        $response->headers->set('Access-Control-Allow-Methods', 'GET, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Accept');

        // Handle preflight OPTIONS requests
        // Story: Before a browser makes the real call, it sends a "scout"
        // request (OPTIONS) to ask "are you accepting visitors from my origin?"
        // We must respond to the scout with 200 OK.
        if ($request->isMethod('OPTIONS')) {
            return response('', 200)
                ->header('Access-Control-Allow-Origin', '*')
                ->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
                ->header('Access-Control-Allow-Headers', 'Content-Type, Accept');
        }

        return $response;
    }
}
