use strict;
use warnings;
use PDL::LiteF;
use PDL::MatrixOps qw(identity);
use PDL::LinearAlgebra;
use PDL::LinearAlgebra::Trans qw //;
use PDL::LinearAlgebra::Real;
use PDL::Complex;
use Test::More;

sub fapprox {
	my($a,$b) = @_;
	(PDL->topdl($a)-$b)->abs->max < 0.0001;
}
sub runtest {
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  my ($in, $method, $expected, $extra) = @_;
  ($expected, my $expected_cplx) = ref($expected) eq 'ARRAY' ? @$expected : ($expected, $expected);
  my ($got) = $in->$method(@{$extra||[]});
  ok fapprox($got, $expected), $method or diag "got(".ref($got)."): $got";
  $_ = PDL::Complex::r2C($_) for $in, $expected_cplx;
  ($got) = $in->$method(map ref() && ref() ne 'CODE' ? PDL::Complex::r2C($_) : $_, @{$extra||[]});
  ok fapprox($got, $expected_cplx), "PDL::Complex $method" or diag "got(".ref($got)."): $got";
}

my $a = pdl([[1.7,3.2],[9.2,7.3]]);
runtest($a, 't', $a->xchg(0,1));

my $aa = cplx random(2,2,2);
runtest($aa, 't', $aa->xchg(1,2)->conj, [1]);

runtest(sequence(2,2), 'issym', 0);

my $x = pdl([0.43,0.03],[0.75,0.72]);
my $wide = pdl([0.43,0.03,0.7],[0.75,0.72,0.2]);
my $rank2 = pdl([1,0,1],[-2,-3,1],[3,3,0]);
my $schur_soln = pdl([0.36637354,-0.72],[0,0.78362646]);
runtest($x, 'mschur', $schur_soln);
runtest($x, 'mschur', $schur_soln, [1,1,1,sub {1}]);
runtest($x, 'mschur', $schur_soln, [1,1,1,undef]);
runtest($x, 'mschur', $schur_soln, [0,1,2,sub {1},0,0]);
runtest($x, 'mschur', $schur_soln, [2,2,2,sub {1},0]);
runtest($x, 'mschur', $schur_soln, [2,2,2,sub {1},1]);
runtest($x, 'mschur', $schur_soln, [2,2,2,sub {1},0,0]);
runtest($x, 'mschur', $schur_soln, [2,2,2,undef,0,0]);
runtest($x, 'mschur', $schur_soln, [0,2,2,undef,0,0]);
runtest(sequence(2,2), 'diag', pdl(0,3));
runtest(sequence(2,2), 'diag', pdl(1), [1]);
runtest(sequence(2,2), 'diag', pdl(2), [-1]);
runtest(sequence(2,2), 'diag', pdl([[0,0],[0,1]],[[2,0],[0,3]]), [0,1]);
runtest(sequence(3,3), 'tritosym', pdl [0,1,2],[1,4,5],[2,5,8]);
runtest(pdl([1,2],[1,0]), 'mrcond', 1/3);
runtest($x, 'mtriinv', pdl([2.3255814,-0.096899225],[0.75,1.3888889]));
runtest($x, 'msyminv', pdl([2.3323615,-0.09718173],[-0.09718173,1.3929381]));
runtest($x->crossprod($x), 'mchol', pdl([0.86452299,0.63954343],[0,0.33209065]));
my $schurx_soln = [pdl([-1.605735,-6],[0,10.605735]),pdl([-1.605735,6],[0,10.605735])];
runtest($a, 'mschurx', $schurx_soln);
runtest($a, 'mschurx', $schurx_soln, [1,1,1,sub {1}]);
runtest($a, 'mschurx', $schurx_soln, [2,2,2,sub {1},0,0]);
runtest($a, 'mschurx', $schurx_soln, [2,2,2,undef,0,0]);
runtest($a, 'mschurx', $schurx_soln, [0,2,2,sub {1},1,0]);
runtest($a, 'mschurx', $schurx_soln, [0,2,2,undef,1,1]);
runtest($a, 'mschurx', $schurx_soln, [0,2,2,sub {1},1,1]);
runtest($a, 'mschurx', $schurx_soln, [0,2,2,sub {1},3,1]);
my @mgschur_exp = (pdl([-0.35099581,-0.68880032],[0,0.81795847]),
  pdl([1.026674, -0.366662], [0, -0.279640]));
runtest($x, 'mgschur', \@mgschur_exp, [sequence(2,2)]);
runtest($x, 'mgschur', \@mgschur_exp, [sequence(2,2),1,1,1,1,sub {1}]);
runtest($x, 'mgschur', \@mgschur_exp, [sequence(2,2),2,2,2,2,sub {1},0]);
runtest($x, 'mgschur', \@mgschur_exp, [sequence(2,2),2,2,2,2,undef,0]);
runtest($x, 'mgschur', \@mgschur_exp, [sequence(2,2),0,0,2,2,sub {1},1,0]);
runtest($x, 'mgschur', \@mgschur_exp, [sequence(2,2),0,0,2,2,undef]);
runtest($x, 'mgschurx', \@mgschur_exp, [sequence(2,2)]);
runtest($x, 'mgschurx', \@mgschur_exp, [sequence(2,2),1,1,1,1,sub {1}]);
runtest($x, 'mgschurx', \@mgschur_exp, [sequence(2,2),2,2,2,2,sub {1},0,0,0]);
runtest($x, 'mgschurx', \@mgschur_exp, [sequence(2,2),2,2,2,2,undef,0,0,0]);
runtest($x, 'mgschurx', \@mgschur_exp, [sequence(2,2),1,1,1,1,sub {1},2]);
runtest($x, 'mgschurx', \@mgschur_exp, [sequence(2,2),1,1,1,1,sub {1},3]);
runtest($x, 'mgschurx', \@mgschur_exp, [sequence(2,2),0,0,1,1,sub {1},1,1,0]);
runtest($x, 'mgschurx', \@mgschur_exp, [sequence(2,2),0,0,2,2,undef]);
runtest($x, 'mqr', pdl([-0.49738411,-0.86753043],[-0.86753043,0.49738411]));
runtest($wide->t, 'mqr', pdl([-0.523069,-0.5023351],[-0.0364932,-0.793903],[-0.851508,0.34260173]));
runtest($x, 'mrq', pdl([0.27614707,-0.3309725],[0,-1.0396634]));
runtest($wide, 'mrq', pdl([0,0.68317233,-0.45724782],[0,0,-1.0587256]), [1]);
runtest($wide->t, 'mrq', pdl([-0.603012,-0.619496],[-0.684055,-0.226644],[0,-0.728010]));
runtest($x, 'mql', pdl([0.99913307,-0.041630545],[-0.041630545,-0.99913307]));
runtest($wide, 'mql', pdl([0.274721,-0.961523],[-0.961523,-0.274721]));
runtest($wide->t, 'mql', pdl([0.6885185,0.155284,-0.708398],[-0.606947,-0.411253,-0.680062],[-0.396935,0.898196,-0.188906]), [1]);
runtest($x, 'mlq', pdl([-0.43104524,0],[-0.79829207,0.66605538]));
runtest($wide, 'mlq', pdl([-0.822070,0,0],[-0.588878,-0.879841,0]), [1]);
runtest($wide, 'mlq', pdl([-0.822070,0],[-0.588878,-0.879841]), [0]);
runtest($wide->t, 'mlq', pdl([-0.864522,0],[-0.639543,0.332090],[-0.521674,-0.507794]));
my $x_soln = pdl([-0.20898642,2.1943574],[2.995472,1.8808777]);
runtest($x, 'msolve', $x_soln, [sequence(2,2)]);
runtest($x, 'msolvex', $x_soln, [sequence(2,2), equilibrate=>1]);
runtest($x, 'mtrisolve', pdl([0,2.3255814],[2.7777778,1.744186]), [1,sequence(2,2)]);
my $x_symsoln = pdl([5.9311981,6.0498221],[-3.4005536,-2.1352313]);
runtest($x, 'msymsolve', $x_symsoln, [1,sequence(2,2)]);
runtest($x, 'msymsolvex', $x_symsoln, [1,sequence(2,2),1]);
runtest($x, 'mlls', $x_soln, [sequence(2,2)]);
my $wide_soln = pdl([1.712813,2.511051,3.30928],[2.706977,3.007326,3.30767],[-1.168170,-0.242816,0.682536]);
my $tall_soln = pdl([4.055021,4.995087],[0.247090,1.330964]);
runtest($wide, 'mlls', $wide_soln, [sequence(3,2)]);
runtest($wide->t, 'mlls', $tall_soln, [sequence(2,3)]);
runtest($x, 'mllsy', $x_soln, [sequence(2,2)]);
runtest($wide, 'mllsy', $wide_soln, [sequence(3,2)]);
runtest($wide->t, 'mllsy', pdl([4.055021,4.995087],[0.247090,1.330964]), [sequence(2,3)]);
runtest($x, 'mllss', $x_soln, [sequence(2,2)]);
runtest($wide, 'mllss', $wide_soln, [sequence(3,2)]);
runtest($wide->t, 'mllss', $tall_soln, [sequence(2,3)]);
runtest(pdl([1,2,3],[2,3,5],[3,4,7],[4,5,9]), 'mllss', pdl([3.333333,2.333333],[-2.666666,-1.666666],[0.666666,0.666666]), [sequence(2,4)]);
runtest($x, 'mlse', pdl([-1,1]), [sequence(2,2),ones(2),ones(2)]);
my ($posdef, $possoln) = (pdl([2,-1,0],[-1,2,-1],[0,-1,2]), pdl([3,4.5,6],[6,8,10],[6,7.5,9]));
runtest($posdef, 'mpossolve', $possoln, [1,sequence(3,3)]);
runtest($posdef, 'mpossolvex', $possoln, [1,sequence(3,3), equilibrate=>1]);
my $x_symgeigen = pdl([-0.271308,0.216112,17.055195]);
runtest(sequence(3,3), 'msymgeigen', $x_symgeigen, [$posdef]);
runtest(sequence(3,3), 'msymgeigenx', $x_symgeigen, [$posdef]);
runtest(sequence(3,3), 'msymgeigenx', $x_symgeigen, [$posdef,0,1]);
runtest($x, 'mglm', pdl([-0.10449321,1.497736],[30.95841,-44.976237]), [sequence(2,2),sequence(2,2)]);
my $x_eigen = pdl([0.366373539549749,0.783626460450251]);
runtest($x, 'meigen', $x_eigen, [1,1]);
runtest($x, 'meigenx', $x_eigen);
runtest($x, 'meigenx', $x_eigen, [rcondition=>'value', vector=>'left']);
runtest($x, 'meigenx', $x_eigen, [rcondition=>'vector', vector=>'right']);
runtest($x, 'meigenx', $x_eigen, [rcondition=>'all', permute=>1, vector=>'all']);
my $x_geigen = [pdl([-0.350995,0.817958]), pdl([1.026674,-0.279640])];
runtest($x, 'mgeigen', $x_geigen, [sequence(2,2),1,1]);
runtest($x, 'mgeigenx', $x_geigen, [sequence(2,2)]);
runtest($x, 'mgeigenx', $x_geigen, [sequence(2,2), rcondition=>'value', vector=>'left']);
runtest($x, 'mgeigenx', $x_geigen, [sequence(2,2), rcondition=>'vector', vector=>'right']);
runtest($x, 'mgeigenx', $x_geigen, [sequence(2,2), rcondition=>'all', error=>1, permute=>1, vector=>'all']);
my $x_symeigen = pdl([0.42692907,0.72307093]);
runtest($x, 'msymeigen', $x_symeigen);
runtest($x, 'msymeigenx', $x_symeigen);
runtest($x, 'msymeigenx', $x_symeigen, [0,1]);
runtest($x, 'msymeigenx', pdl(-0.188888,1.338888), [1]);
runtest($x, 'mdsvd', pdl([0.32189374,0.9467758],[0.9467758,-0.32189374]));
runtest($x, 'mgsvd', pdl(0.16914549,0.64159379), [sequence(2,2), all=>1]);
runtest(sequence(5,3)->t+1, 'mgsvd', pdl(0.980672,0.315531,0), [pdl([8,1,6],[3,5,7],[4,9,2]), all=>1]);
runtest($a, 'mdet', -17.03);
runtest($a->mcos, 'macos', pdl([[1.7018092, 0.093001244],[0.26737858,1.8645614]]));
runtest($a->msin, 'masin', pdl([[-1.4397834,0.093001244],[0.26737858,-1.2770313]]));
runtest($a->mexp, 'mlog', $a);
runtest($a, 'morth', pdl([-0.275682, 0.961248],[-0.961248,-0.275682]));
runtest($rank2, 'mnull', pdl(-0.5773502,0.5773502,0.5773502)->t);
runtest($a, 'mpinv', pdl([-0.428655,0.187903],[0.540223,-0.099823]));
runtest($a, 'mlu', pdl([1,0],[0.184782,1]));
runtest($wide->t, 'mlu', pdl([1,0],[0.042857,1],[0.614285,0.881526]));
runtest(sequence(3,3), 'mhessen', pdl([0,-2.236068,0],[-6.708203,12,3],[0,1,0]));
runtest($a, 'mrank', 2);
runtest($rank2, 'mrank', 2);
runtest($a, 'mnorm', 12.211267);
runtest($a, 'msvd', pdl(12.211267,1.3946136), [0,0]);
runtest($a, 'mcond', 8.756021);

ok all(approx pdl([1,1,-1],[-1,-1,2])->positivise, pdl([1,1,-1],[1,1,-2])), 'positivise'; # real only

my $id = pdl([[1,0],[0,1]]);
ok(fapprox($a->minv x $a,$id));

ok(fapprox($a->mcrossprod->mposinv->tritosym x $a->mcrossprod,$id));

ok($a->mcrossprod->mposdet !=0);

my $A = identity(4) + ones(4, 4);
$A->slice('2,0') .= 0; # if don't break symmetry, don't show need transpose
my $B = sequence(2, 4);
getrf(my $lu=$A->copy, my $ipiv=null, my $info=null);
# if don't transpose the $B input, get memory crashes
getrs($lu, 1, $x=$B->xchg(0,1)->copy, $ipiv, $info=null);
$x = $x->inplace->xchg(0,1);
my $got = $A x $x;
ok fapprox($got, $B) or diag "got: $got";

$A=pdl cdouble, <<'EOF';
[
 [  1   0   0   0   0   0]
 [0.5   1   0 0.5   0   0]
 [0.5   0   1   0   0 0.5]
 [  0   0   0   1   0   0]
 [  0   0   0 0.5   1 0.5]
 [  0   0   0   0   0   1]
]
EOF
PDL::LinearAlgebra::Complex::cgetrf($lu=$A->copy, $ipiv=null, $info=null);
is $info, 0, 'cgetrf native worked';
is $ipiv->nelem, 6, 'cgetrf gave right-sized ipiv';
$B=pdl q[0.233178433563939+0.298197173371207i 1.09431208340166+1.30493506686269i 1.09216041861621+0.794394153882734i 0.55609433247125+0.515431151337765i 0.439100406078467+1.39139453403467i 0.252359761958406+0.570614019329113i];
PDL::LinearAlgebra::Complex::cgetrs($lu, 1, $x=$B->copy, $ipiv, $info=null);
is $info, 0;
$x = $x->dummy(0); # transpose; xchg rightly fails if 1-D
$got = $A x $x;
ok fapprox($got, $B->dummy(0)) or diag "got: $got";
my $i=pdl('i'); # Can't use i() as it gets confused by PDL::Complex's i()
my $complex_matrix=(1+sequence(2,2))*$i;
$got=$complex_matrix->mdet;
ok(fapprox($got, 2), "Complex mdet") or diag "got $got";

done_testing;
