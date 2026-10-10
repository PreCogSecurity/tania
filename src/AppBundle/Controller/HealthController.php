<?php

namespace AppBundle\Controller;

use Doctrine\DBAL\Connection;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class HealthController extends Controller
{
    /**
     * Health check endpoint for load balancers and monitoring.
     *
     * @Route("/health", name="health_check", methods={"GET", "HEAD"})
     */
    public function healthAction(Connection $connection)
    {
        $checks = [
            'status' => 'healthy',
            'checks' => [],
        ];

        // Database connectivity check
        try {
            $connection->connect();
            $connection->executeQuery('SELECT 1');
            $checks['checks']['database'] = [
                'status' => 'healthy',
                'message' => 'Database connection successful',
            ];
        } catch (\Exception $e) {
            $checks['status'] = 'unhealthy';
            $checks['checks']['database'] = [
                'status' => 'unhealthy',
                'message' => 'Database connection failed: ' . $e->getMessage(),
            ];
        }

        // Cache directory writable check
        $cacheDir = $this->getParameter('kernel.cache_dir');
        if (is_writable($cacheDir)) {
            $checks['checks']['cache'] = [
                'status' => 'healthy',
                'message' => 'Cache directory is writable',
            ];
        } else {
            $checks['status'] = 'unhealthy';
            $checks['checks']['cache'] = [
                'status' => 'unhealthy',
                'message' => 'Cache directory is not writable',
            ];
        }

        // Logs directory writable check
        $logsDir = $this->getParameter('kernel.logs_dir');
        if (is_writable($logsDir)) {
            $checks['checks']['logs'] = [
                'status' => 'healthy',
                'message' => 'Logs directory is writable',
            ];
        } else {
            $checks['status'] = 'unhealthy';
            $checks['checks']['logs'] = [
                'status' => 'unhealthy',
                'message' => 'Logs directory is not writable',
            ];
        }

        $statusCode = $checks['status'] === 'healthy' ? Response::HTTP_OK : Response::HTTP_SERVICE_UNAVAILABLE;

        return new JsonResponse($checks, $statusCode);
    }
}