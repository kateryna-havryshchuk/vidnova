using System.Reflection;
using Mapster;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using Vidnova.Application.Services.Auth;
using Vidnova.Application.Services.CheckIns;
using Vidnova.Application.Services.Journal.Abc;

namespace Vidnova.Application.DependencyInjection;

public static class ApplicationServiceRegistration
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        var config = TypeAdapterConfig.GlobalSettings;
        config.Scan(Assembly.GetExecutingAssembly());
        services.AddSingleton(config);
        services.AddScoped<IMapper, ServiceMapper>();

        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IMeService, MeService>();
        services.AddScoped<IUserCredentialsService, UserCredentialsService>();
        services.AddScoped<IUserAccountService, UserAccountService>();
        services.AddScoped<IDailyCheckInService, DailyCheckInService>();
        services.AddScoped<IDailyCheckInAiInsightService, DailyCheckInAiInsightService>();
        services.AddScoped<IAbcEntryService, AbcEntryService>();
        return services;
    }
}