// This file is part of prometheus
// Copyright (C) 2022-2025 Life4gal <life4gal@gmail.com>
// This file is subject to the license terms in the LICENSE file
// found in the top-level directory of this distribution.

#pragma once

#include <format>

#include <prometheus/platform/exception.hpp>

namespace prometheus::clp
{
	class NameFormatError final : public platform::Exception<void>
	{
	public:
		using Exception::Exception;

		[[noreturn]] static auto panic(
			const std::string_view option_name,
			const std::source_location& location = std::source_location::current(),
			std::stacktrace stacktrace = std::stacktrace::current()
		) noexcept(false) -> void
		{
			platform::panic<NameFormatError>(
				std::format("Cannot parse `{}` as option name", option_name),
				location,
				std::move(stacktrace)
			);
		}
	};

	class AlreadyExistsError final : public platform::Exception<void>
	{
	public:
		using Exception::Exception;

		[[noreturn]] static auto panic(
			const std::string_view option_name,
			const std::source_location& location = std::source_location::current(),
			std::stacktrace stacktrace = std::stacktrace::current()
		) noexcept(false) -> void
		{
			platform::panic<AlreadyExistsError>(
				std::format("Option `{}` already exists!", option_name),
				location,
				std::move(stacktrace)
			);
		}
	};

	class UnrecognizedError final : public platform::Exception<void>
	{
	public:
		using Exception::Exception;

		[[noreturn]] static auto panic(
			const std::string_view option_name,
			const std::source_location& location = std::source_location::current(),
			std::stacktrace stacktrace = std::stacktrace::current()
		) noexcept(false) -> void
		{
			platform::panic<UnrecognizedError>(
				std::format("Unrecognized option:\n {}", option_name),
				location,
				std::move(stacktrace)
			);
		}
	};

	class RequiredNotPresentError final : public platform::Exception<void>
	{
	public:
		using Exception::Exception;

		[[noreturn]] static auto panic(
			const std::string_view option_name,
			const std::source_location& location = std::source_location::current(),
			std::stacktrace stacktrace = std::stacktrace::current()
		) noexcept(false) -> void
		{
			platform::panic<RequiredNotPresentError>(
				std::format("Required option `{}` not present", option_name),
				location,
				std::move(stacktrace)
			);
		}
	};

	class RequiredNotSetError final : public platform::Exception<void>
	{
	public:
		using Exception::Exception;

		[[noreturn]] static auto panic(
			const std::string_view option_name,
			const std::source_location& location = std::source_location::current(),
			std::stacktrace stacktrace = std::stacktrace::current()
		) noexcept(false) -> void
		{
			platform::panic<RequiredNotSetError>(
				std::format("Required option `{}` not set and no default value present", option_name),
				location,
				std::move(stacktrace)
			);
		}
	};
}
