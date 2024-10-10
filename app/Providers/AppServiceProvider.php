<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\URL;

class AppServiceProvider extends ServiceProvider
{
    public function boot()
    {
        if($this->app->environment('production')) {
            URL::forceScheme('https');
        }

        // Force secure cookies in production
        if(request()->isSecure()) {
            config([
                'session.secure' => true,
                'session.same_site' => 'lax'
            ]);
        }
    }
}