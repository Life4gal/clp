#define PROMETHEUS_CLP_USE_EXPECTED 1

#include <cassert>

#include <prometheus/command_line_parser/command_line_parser.hpp>

using namespace prometheus;
using std::string_literals::operator""s;
using std::string_view_literals::operator""sv;

auto main() noexcept -> int
{
	using parser_type = clp::OptionParser<>;
	using option_type = parser_type::option_type;

	clp::OptionParser parser{};

	parser
			// options
			.add_option("tab-width", option_type::default_value("4"))
			.add_option("encoding", option_type::default_value("utf-8"))
			.add_option("window-position-x, wpx", option_type::default_value("100"))
			.add_option("window-position-y, wpy", option_type::default_value("100"))
			.add_option("window-size-w, wsw", option_type::default_value("720"))
			.add_option("window-size-h, wsh", option_type::default_value("480"))
			.add_option("auto-save, as", option_type::implicit_value("true"))
			.add_option("auto-reload, ar", option_type::implicit_value("false"))
			.add_option("auto-flush, af")
			// aliases
			.add_alias("tw", "tab-width")
			.add_alias("e", "encoding")
			// test options
			.add_option("option-name1")
			.add_option("option_name2")
			.add_option("option.name3");

	constexpr std::array args
	{
			// tab-width == 2
			"--tab-width=2"sv,
			// encoding == utf-8(default)
			"--encoding"sv,
			// window-position-x == unspecified
			//
			// window-position-y == 200
			"--window-position-y=200"sv,
			// window-size-w == unspecified
			// specified, invalid integer
			// parser["window-size-w"].set() == true
			"-window-size-w"sv,
			// window-size-h == 480(default)
			"--window-size-h"sv,
			// auto-save == true(implicit)
			//
			// auto-reload == false(implicit)
			//
			// auto-flush == unspecified
			//
			// option-name1 == [1,2,3,4,5](std::vector<int>)
			"--option-name1=1,2,3,4,5"sv,
			// option_name2 == [abc,def,ghi](std::vector<std::string>)
			"--option_name2=abc,def,ghi"sv,
			// option.name3 == unspecified
			// empty, no value
			// parser["option.name3"].set() == false
			"--option.name3="sv,
	};

	try
	{
		parser.parse(args);
	}
	catch (const platform::IException& exception)
	{
		exception.print();
		return 1;
	}

	std::println("ARGS:");

	std::println("\t{}", args);

	// options
	const auto tab_width = parser["tab-width"].as<std::size_t>();
	const auto encoding = parser["encoding"].as<std::string>();
	const auto wpx = parser["wpx"].as<int>();
	const auto wpy = parser["wpy"].as<int>();
	const auto wsw = parser["wsw"].as<int>();
	const auto wsh = parser["wsh"].as<int>();
	const auto as = parser["as"].as<bool>();
	const auto ar = parser["ar"].as<bool>();
	const auto af = parser["af"].as<bool>();

	std::println("OPTIONS:");

	assert(tab_width.has_value() && tab_width.value() == 2);
	std::println("\ttab-width: {}", tab_width.value()); // NOLINT(bugprone-unchecked-optional-access)

	assert(encoding.has_value() && encoding.value() == "utf-8"sv);
	std::println("\tencoding: {}", encoding.value()); // NOLINT(bugprone-unchecked-optional-access)

	assert(!wpx.has_value());
	std::println("\twindows-position-x: unspecified");

	assert(wpy.has_value() && wpy.value() == 200);
	std::println("\twindows-position-y: {}", wpy.value()); // NOLINT(bugprone-unchecked-optional-access)

	assert(parser["wsw"].set() == true && not wsw.has_value());
	std::println("\twindow-size-width: unspecified");

	assert(wsh.has_value() && wsh.value() == 480);
	std::println("\twindow-size-height: {}", wsh.value()); // NOLINT(bugprone-unchecked-optional-access)

	assert(as.has_value() && as.value() == true);
	std::println("\tauto-save: {}", as.value()); // NOLINT(bugprone-unchecked-optional-access)

	assert(ar.has_value() && ar.value() == false);
	std::println("\tauto-reload: {}", ar.value()); // NOLINT(bugprone-unchecked-optional-access)

	assert(!af.has_value());
	std::println("\tauto-flush: unspecified");

	// aliases
	const auto tw = parser["tw"].as<std::size_t>();
	const auto e = parser["e"].as<std::string>();

	std::println("ALIASES:");

	assert(tw.has_value() && tw.value() == 2);
	std::println("\ttab-width(tw): {}", tw.value()); // NOLINT(bugprone-unchecked-optional-access)

	assert(e.has_value() && e.value() == "utf-8"sv);
	std::println("\tencoding(e): {}", e.value()); // NOLINT(bugprone-unchecked-optional-access)

	// test options
	const auto option1 = parser["option-name1"].as<std::vector<int>>();
	const auto option2 = parser["option_name2"].as<std::vector<std::string>>();
	const auto option3 = parser["option.name3"].as<std::vector<std::string>>();

	std::println("TEST OPTIONS:");

	assert(option1.has_value() && (option1.value() == std::vector{1, 2, 3, 4, 5}));
	std::println("\toption-name1: {}", option1.value()); // NOLINT(bugprone-unchecked-optional-access)

	assert(option2.has_value() && (option2.value() == std::vector{"abc"s, "def"s, "ghi"s}));
	std::println("\toption_name2: {}", option2.value()); // NOLINT(bugprone-unchecked-optional-access)

	assert(parser["option.name3"].set() == false && !option3.has_value());
	std::println("\toption.name3: unspecified");
}
