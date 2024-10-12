<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\App;

class HttpsProtocol
{
    public function handle($request, Closure $next)
    {
        if (!$request->secure() && App::environment() === 'production' && !$this->isHttps($request)) {
            return redirect()->secure($request->getRequestUri());
        }
        return $next($request);
    }

    private function isHttps($request)
    {
        $xForwardedProto = $request->header('X-Forwarded-Proto');
        $xForwardedSsl = $request->header('X-Forwarded-Ssl');

        return $request->secure()
            || $request->isSecure()
            || (isset($xForwardedProto) && $xForwardedProto == 'https')
            || (isset($xForwardedSsl) && $xForwardedSsl == 'on');
    }
}