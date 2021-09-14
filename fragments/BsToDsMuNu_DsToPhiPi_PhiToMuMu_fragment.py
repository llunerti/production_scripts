import FWCore.ParameterSet.Config as cms

from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunes2017.PythiaCP5Settings_cfi import *
from GeneratorInterface.EvtGenInterface.EvtGenSetting_cff import *

_generator = cms.EDFilter(
    "Pythia8GeneratorFilter",
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    maxEventsToPrint = cms.untracked.int32(0),
    pythiaPylistVerbosity = cms.untracked.int32(0),
    comEnergy = cms.double(13000.0),
    ExternalDecays = cms.PSet(
        EvtGen130 = cms.untracked.PSet(
            decay_table = cms.string('GeneratorInterface/EvtGenInterface/data/DECAY_2014_NOLONGLIFE.DEC'),
            particle_property_file = cms.FileInPath('GeneratorInterface/EvtGenInterface/data/evt_2014.pdl'),
            list_forced_decays = cms.vstring('MyB_s0', 'Myanti-B_s0','MyD_s+','MyD_s-','MyPhi'),
            operates_on_particles = cms.vint32(),
            convertPythiaCodes = cms.untracked.bool(False),
            user_decay_embedded = cms.vstring(
                'Alias      MyB_s0      B_s0',
                'Alias      Myanti-B_s0 anti-B_s0',
                'Alias      MyD_s+      D_s+',
                'Alias      MyD_s-      D_s-',
                'Alias      MyPhi       phi',
                'ChargeConj Myanti-B_s0 MyB_s0 ',
                'ChargeConj MyD_s+ MyD_s-',
                'ChargeConj MyPhi MyPhi',
                'Decay MyB_s0',
                '1.000      MyD_s-  mu+   nu_mu     ISGW2;',
                'Enddecay',
                'CDecay Myanti-B_s0',
                'Decay MyD_s+',
                '1.000      MyPhi  pi+     SVS;',
                'Enddecay',
                'CDecay MyD_s-',
                'Decay MyPhi',
                '1.000      mu+  mu-     VLL;',
                'Enddecay',
                'End'
            )
        ),
        parameterSets = cms.vstring('EvtGen130')
    ),
    PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        processParameters = cms.vstring(
            "SoftQCD:nonDiffractive = on",
            'PTFilter:filter = on', # this turn on the filter
            'PTFilter:quarkToFilter = 5', # PDG id of q quark
            'PTFilter:scaleToFilter = 1.0'),
        parameterSets = cms.vstring(
            'pythia8CommonSettings',
            'pythia8CP5Settings',
            'processParameters',
        )
    )
)

from GeneratorInterface.Core.ExternalGeneratorFilter import ExternalGeneratorFilter
generator = ExternalGeneratorFilter(_generator, _external_process_waitTime_=cms.untracked.uint32(300)) 
#generator = ExternalGeneratorFilter(_generator) 

generator.PythiaParameters.processParameters.extend(EvtGenExtraParticles)

bfilter = cms.EDFilter(
    "PythiaFilter",
    MaxEta = cms.untracked.double(9999.),
    MinEta = cms.untracked.double(-9999.),
    ParticleID = cms.untracked.int32(531)
)

#Filter Phi->MuMu
phidecayfilter = cms.EDFilter(
    "PythiaDauVFilter",
    verbose         = cms.untracked.int32(0),
    NumberDaughters = cms.untracked.int32(2),
    MotherID        = cms.untracked.int32(431),
    ParticleID      = cms.untracked.int32(333),
    DaughterIDs     = cms.untracked.vint32(-13,13),
    MinPt           = cms.untracked.vdouble(2., 2.),
    MinEta          = cms.untracked.vdouble(-2.5, -2.5),
    MaxEta          = cms.untracked.vdouble( 2.5,  2.5)
)

ProductionFilterSequence = cms.Sequence(generator*phidecayfilter*bfilter)
