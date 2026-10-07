<?php

namespace Database\Seeders;

use App\Models\Film;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        Film::factory()->create([
            'title' => 'Inception',
            'genre' => 'Sci-Fi',
            'rating' => 5,
        ]);

        Film::factory()->create([
            'title' => 'The Dark Knight',
            'genre' => 'Action',
            'rating' => 5,
        ]);

        Film::factory()->create([
            'title' => 'Interstellar',
            'genre' => 'Sci-Fi',
            'rating' => 5,
        ]);
    }
}
