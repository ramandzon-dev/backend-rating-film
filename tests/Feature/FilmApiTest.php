<?php

namespace Tests\Feature;

use App\Models\Film;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FilmApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_all_films(): void
    {
        Film::factory()->count(3)->create();

        $response = $this->getJson('/api/films');

        $response->assertStatus(200)
            ->assertJsonCount(3);
    }

    public function test_can_create_film(): void
    {
        $payload = [
            'title' => 'Inception',
            'genre' => 'Sci-Fi',
            'rating' => 5,
        ];

        $response = $this->postJson('/api/films', $payload);

        $response->assertStatus(201)
            ->assertJson([
                'message' => 'Film berhasil ditambahkan',
                'data' => [
                    'title' => 'Inception',
                    'genre' => 'Sci-Fi',
                    'rating' => 5,
                ],
            ]);

        $this->assertDatabaseHas('films', [
            'title' => 'Inception',
            'genre' => 'Sci-Fi',
            'rating' => 5,
        ]);
    }

    public function test_validate_film_creation_rules(): void
    {
        $response = $this->postJson('/api/films', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title', 'genre', 'rating']);
    }

    public function test_can_show_single_film(): void
    {
        $film = Film::factory()->create([
            'title' => 'Interstellar',
            'genre' => 'Sci-Fi',
            'rating' => 5,
        ]);

        $response = $this->getJson("/api/films/{$film->id}");

        $response->assertStatus(200)
            ->assertJson([
                'id' => $film->id,
                'title' => 'Interstellar',
                'genre' => 'Sci-Fi',
                'rating' => 5,
            ]);
    }

    public function test_can_update_film(): void
    {
        $film = Film::factory()->create([
            'title' => 'Old Title',
            'genre' => 'Action',
            'rating' => 3,
        ]);

        $updateData = [
            'title' => 'Updated Title',
            'genre' => 'Action/Thriller',
            'rating' => 4,
        ];

        $response = $this->putJson("/api/films/{$film->id}", $updateData);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Film berhasil diperbarui',
                'data' => [
                    'id' => $film->id,
                    'title' => 'Updated Title',
                    'genre' => 'Action/Thriller',
                    'rating' => 4,
                ],
            ]);

        $this->assertDatabaseHas('films', [
            'id' => $film->id,
            'title' => 'Updated Title',
        ]);
    }

    public function test_can_delete_film(): void
    {
        $film = Film::factory()->create();

        $response = $this->deleteJson("/api/films/{$film->id}");

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Film berhasil dihapus',
            ]);

        $this->assertDatabaseMissing('films', [
            'id' => $film->id,
        ]);
    }

    public function test_validate_film_invalid_rating(): void
    {
        $response = $this->postJson('/api/films', [
            'title' => 'Invalid Rating Film',
            'genre' => 'Action',
            'rating' => 10,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['rating']);
    }

    public function test_show_non_existent_film_returns_404(): void
    {
        $response = $this->getJson('/api/films/99999');

        $response->assertStatus(404);
    }
}
