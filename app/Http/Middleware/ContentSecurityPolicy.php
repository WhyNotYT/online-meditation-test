<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ContentSecurityPolicy
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);
        
        $response->headers->set('Content-Security-Policy', "
            default-src 'self';
            script-src 'self' 'unsafe-inline' 'unsafe-eval';
            style-src 'self' 'unsafe-inline';
            img-src 'self' data: https:;
            font-src 'self' data:;
            connect-src 'self';
            media-src 'self';
            object-src 'none';
            frame-src 'self';
            worker-src 'self';
            frame-ancestors 'self';
            form-action 'self';
            base-uri 'self';
            manifest-src 'self'
        ");
        
        return $response;
    }
}